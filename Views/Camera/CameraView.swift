import AVFoundation
import SwiftUI
import UIKit

// MARK: - Вспомогательные классы и протоколы

// Делегат для обработки захвата фото
class CameraViewCoordinator: NSObject, AVCapturePhotoCaptureDelegate {
    let parent: CameraView
    
    init(parent: CameraView) {
        self.parent = parent
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            parent.viewModel.setError("Ошибка при захвате фото: \(error.localizedDescription)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            parent.viewModel.setError("Не удалось получить данные изображения")
            return
        }
        
        guard let image = UIImage(data: imageData) else {
            parent.viewModel.setError("Не удалось создать изображение из данных")
            return
        }
        
        // Проверяем ориентацию и корректируем при необходимости
        var finalImage = image
        
        // Уменьшаем изображение до оптимального размера для ML
        finalImage = parent.viewModel.resizeImage(image: finalImage, maxDimension: Config.TryOn.maxImageDimension)
        
        DispatchQueue.main.async { [weak self] in
            self?.parent.viewModel.statusMessage = nil
            self?.parent.capturedImage = finalImage
            self?.parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// Класс модели представления камеры
class CameraViewModel: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var lightLevel: Double = 0.5
    @Published var statusMessage: String?
    @Published var statusIsWarning: Bool = false
    @Published var resultImage: UIImage?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var isConfigured = false
    private var camera: AVCaptureDevice?
    private var photoOutput = AVCapturePhotoOutput()
    private var captureQueue = DispatchQueue(label: "captureQueue")
    private var lastLightMeasurement = Date()
    private var lightnessTimer: Timer?
    
    override init() {
        super.init()
    }
    
    func checkPermissionsAndStartSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    DispatchQueue.main.async {
                        self.setupSession()
                    }
                } else {
                    self.setError("Нет доступа к камере")
                }
            }
        default:
            self.setError("Нет доступа к камере")
        }
    }
    
    func setupSession() {
        captureQueue.async { [weak self] in
            guard let self = self else { return }
            
            guard !self.isConfigured else { return }
            
            self.session.beginConfiguration()
            
            // Установка высокого разрешения для качественного изображения
            self.session.sessionPreset = .high
            
            guard let camera = self.getBestCamera() else {
                self.setError("Не удалось инициализировать камеру")
                return
            }
            
            self.camera = camera
            
            do {
                // Настраиваем вход
                let input = try AVCaptureDeviceInput(device: camera)
                
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                } else {
                    self.setError("Не удалось добавить вход камеры")
                    self.session.commitConfiguration()
                    return
                }
                
                // Настраиваем выход
                if self.session.canAddOutput(self.photoOutput) {
                    self.session.addOutput(self.photoOutput)
                } else {
                    self.setError("Не удалось добавить выход для фото")
                    self.session.commitConfiguration()
                    return
                }
                
                self.session.commitConfiguration()
                self.isConfigured = true
                
                // Запускаем сессию
                self.session.startRunning()
                
                // Запускаем таймер для измерения освещенности
                DispatchQueue.main.async {
                    self.startLightnessTimer()
                }
            } catch {
                self.setError("Ошибка настройки камеры: \(error.localizedDescription)")
            }
        }
    }
    
    func stopSession() {
        captureQueue.async { [weak self] in
            guard let self = self else { return }
            
            if self.session.isRunning {
                self.session.stopRunning()
            }
            
            DispatchQueue.main.async {
                self.lightnessTimer?.invalidate()
                self.lightnessTimer = nil
            }
        }
    }
    
    func capturePhoto(coordinator: CameraViewCoordinator) {
        guard session.isRunning else {
            return
        }
        
        if lightLevel < 0.4 {
            statusMessage = "Недостаточное освещение для хорошего фото"
            statusIsWarning = true
            
            // Даем обратную связь через вибрацию
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            
            // Продолжаем с захватом фото несмотря на предупреждение
        } else {
            statusMessage = "Захват фото..."
            statusIsWarning = false
        }
        
        let settings = AVCapturePhotoSettings()
        
        // Оптимизируем настройки для рук
        settings.flashMode = .auto
        
        if let previewPhotoPixelFormatType = settings.availablePreviewPhotoPixelFormatTypes.first {
            settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
        }
        
        photoOutput.capturePhoto(with: settings, delegate: coordinator)
    }
    
    func switchCamera() {
        stopSession()
        
        // Ждем остановки сессии
        captureQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.isConfigured = false
            // Очищаем текущие входы/выходы
            for input in self.session.inputs {
                self.session.removeInput(input)
            }
            for output in self.session.outputs {
                self.session.removeOutput(output)
            }
            
            DispatchQueue.main.async {
                self.setupSession()
            }
        }
    }
    
    private func getBestCamera() -> AVCaptureDevice? {
        // По умолчанию используем заднюю камеру (она обычно лучшего качества)
        if let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            do {
                try backCamera.lockForConfiguration()
                // Настраиваем автофокус для руки (обычно на расстоянии 20-40 см)
                if backCamera.isFocusModeSupported(.continuousAutoFocus) {
                    backCamera.focusMode = .continuousAutoFocus
                }
                
                // Включаем автоматическую настройку экспозиции
                if backCamera.isExposureModeSupported(.continuousAutoExposure) {
                    backCamera.exposureMode = .continuousAutoExposure
                }
                
                // Включаем автоматический баланс белого
                if backCamera.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                    backCamera.whiteBalanceMode = .continuousAutoWhiteBalance
                }
                
                backCamera.unlockForConfiguration()
                return backCamera
            } catch {
                print("Ошибка настройки камеры: \(error)")
            }
        }
        
        // Если задняя недоступна, используем переднюю
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    }
    
    private func startLightnessTimer() {
        lightnessTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.measureLightLevel()
        }
    }
    
    func measureLightLevel() {
        guard let camera = camera, Date().timeIntervalSince(lastLightMeasurement) > 0.2 else { return }
        lastLightMeasurement = Date()
        
        do {
            try camera.lockForConfiguration()
            
            // ISO и выдержка помогают оценить освещенность
            let currentISO = camera.iso
            let currentExposureDuration = camera.exposureDuration
            
            let maxISO = camera.activeFormat.maxISO
            
            // Если ISO близко к максимальному, вероятно, недостаточно света
            // Если выдержка длинная, также недостаточно света
            let normalizedISO = min(currentISO / maxISO, 1.0)
            let exposureFactor = 1.0 - min(currentExposureDuration.seconds / 0.25, 1.0)
            
            let calculatedLightLevel = exposureFactor * (1.0 - Double(normalizedISO))
            
            camera.unlockForConfiguration()
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                // Сглаживаем изменения, чтобы избежать резких скачков
                self.lightLevel = self.lightLevel * 0.7 + calculatedLightLevel * 0.3
                
                // Обновляем сообщение в зависимости от уровня освещения
                if self.lightLevel < 0.3 {
                    self.statusMessage = "Слишком темно. Найдите более яркое освещение."
                    self.statusIsWarning = true
                } else if self.lightLevel < 0.4 {
                    self.statusMessage = "Недостаточное освещение. Рекомендуется улучшить."
                    self.statusIsWarning = true
                } else if self.lightLevel > 0.85 {
                    self.statusMessage = "Слишком яркое освещение. Избегайте прямого солнечного света."
                    self.statusIsWarning = true
                } else {
                    self.statusMessage = "Хорошее освещение. Расположите руку в контуре."
                    self.statusIsWarning = false
                }
            }
            
        } catch {
            print("Ошибка измерения освещенности: \(error)")
        }
    }
    
    func setError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.statusMessage = message
            self?.statusIsWarning = true
        }
    }
    
    // Исправлен метод resizeImage для соответствия сигнатуре в исходном коде
    func resizeImage(image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        
        // Если изображение уже меньше максимального размера, вернуть его как есть
        if size.width <= maxDimension && size.height <= maxDimension {
            return image
        }
        
        // Вычисляем новые размеры, сохраняя соотношение сторон
        var newWidth: CGFloat
        var newHeight: CGFloat
        
        if size.width > size.height {
            newWidth = maxDimension
            newHeight = size.height * maxDimension / size.width
        } else {
            newHeight = maxDimension
            newWidth = size.width * maxDimension / size.height
        }
        
        let targetSize = CGSize(width: newWidth, height: newHeight)
        
        // Изменяем размер изображения
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
    
    // Метод определения уровня освещения переименован, чтобы избежать конфликта с существующим методом
    func checkLightingLevel(_ image: UIImage) -> Double {
        guard let cgImage = image.cgImage else { return 0.5 }
        
        // Уменьшаем изображение для более быстрого анализа
        let width = 100
        let height = 100
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let context = CGContext(data: nil, width: width, height: height,
                                     bitsPerComponent: 8, bytesPerRow: width * 4,
                                     space: CGColorSpaceCreateDeviceRGB(),
                                     bitmapInfo: bitmapInfo.rawValue) else {
            return 0.5
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let pixelData = context.data else { return 0.5 }
        
        let data = pixelData.bindMemory(to: UInt8.self, capacity: width * height * 4)
        
        var totalBrightness: Double = 0
        var pixelCount: Double = 0
        
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                let r = Double(data[offset])
                let g = Double(data[offset + 1])
                let b = Double(data[offset + 2])
                
                // Вычисляем яркость пикселя (средневзвешенное значение RGB)
                let brightness = (0.299 * r + 0.587 * g + 0.114 * b) / 255.0
                totalBrightness += brightness
                pixelCount += 1
            }
        }
        
        // Средняя яркость всего изображения
        let averageBrightness = pixelCount > 0 ? totalBrightness / pixelCount : 0.5
        
        // Нормализуем в диапазон 0.0-1.0
        return averageBrightness
    }
}

// MARK: - Основная структура камеры

struct CameraView: View {
    @ObservedObject var viewModel = CameraViewModel()
    @Environment(\.presentationMode) var presentationMode
    @Binding var capturedImage: UIImage?
    
    // Координатор для обработки захвата фото
    func makeCoordinator() -> CameraViewCoordinator {
        return CameraViewCoordinator(parent: self)
    }
    
    var body: some View {
        ZStack {
            // Градиентный фон
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Основное содержимое
            VStack {
                Text("Фото руки")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 16)
                
                // Увеличиваем размер предпросмотра камеры
                ZStack {
                    // Превью камеры на весь экран
                    CameraPreviewView(session: viewModel.session)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                    
                    // Направляющие для руки - более детальный контур
                    HandShapeOverlayView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 20)
                    
                    // Индикатор освещения
                    VStack {
                        Spacer()
                        LightLevelIndicator(lightLevel: viewModel.lightLevel)
                            .padding(.bottom, 10)
                    }
                }
                .frame(maxHeight: .infinity)
                
                // Уведомления и подсказки
                if let message = viewModel.statusMessage {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(viewModel.statusIsWarning ? .red : .white)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(8)
                        .padding(.vertical, 8)
                }
                
                // Кнопки управления
                HStack(spacing: 50) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        viewModel.capturePhoto(coordinator: makeCoordinator())
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 72, height: 72)
                            Circle()
                                .stroke(Color.white.opacity(0.8), lineWidth: 2)
                                .frame(width: 82, height: 82)
                        }
                    }
                    
                    Button(action: {
                        viewModel.switchCamera()
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath.camera.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            viewModel.checkPermissionsAndStartSession()
        }
        .onDisappear {
            viewModel.stopSession()
        }
    }
}

// Представление предпросмотра камеры
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Важное улучшение: добавляем тег к слою предпросмотра для отладки
        previewLayer.name = "CameraPreviewLayer"
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
            
            // Отладочная информация
            print("CameraPreviewView обновлена с размерами: \(uiView.bounds.width) x \(uiView.bounds.height)")
        } else {
            print("ОШИБКА: Слой предпросмотра не найден!")
        }
    }
}

// Улучшенный контур руки с использованием реального контура, а не овала
struct HandShapeOverlayView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Затемнение фона, кроме области руки
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                // Внутренний контур руки (более детальный)
                HandShape()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.7)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .blendMode(.destinationOut)
                
                // Надпись с инструкцией
                VStack {
                    Text("Расположите руку в контуре")
                        .font(.headline)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                        .padding(.top, 20)
                    
                    Spacer()
                }
            }
        }
    }
}

// Форма руки для более точного контура
struct HandShape: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        
        var path = Path()
        
        // Начинаем с нижней левой части ладони
        path.move(to: CGPoint(x: width * 0.2, y: height * 0.8))
        
        // Левая сторона ладони
        path.addCurve(
            to: CGPoint(x: width * 0.2, y: height * 0.3),
            control1: CGPoint(x: width * 0.15, y: height * 0.7),
            control2: CGPoint(x: width * 0.15, y: height * 0.4)
        )
        
        // Мизинец
        path.addCurve(
            to: CGPoint(x: width * 0.28, y: height * 0.18),
            control1: CGPoint(x: width * 0.22, y: height * 0.25),
            control2: CGPoint(x: width * 0.25, y: height * 0.2)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.35, y: height * 0.25),
            control1: CGPoint(x: width * 0.32, y: height * 0.15),
            control2: CGPoint(x: width * 0.35, y: height * 0.2)
        )
        
        // Безымянный палец
        path.addCurve(
            to: CGPoint(x: width * 0.43, y: height * 0.12),
            control1: CGPoint(x: width * 0.37, y: height * 0.2),
            control2: CGPoint(x: width * 0.4, y: height * 0.15)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.2),
            control1: CGPoint(x: width * 0.46, y: height * 0.09),
            control2: CGPoint(x: width * 0.5, y: height * 0.15)
        )
        
        // Средний палец
        path.addCurve(
            to: CGPoint(x: width * 0.6, y: height * 0.1),
            control1: CGPoint(x: width * 0.52, y: height * 0.15),
            control2: CGPoint(x: width * 0.57, y: height * 0.12)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.65, y: height * 0.2),
            control1: CGPoint(x: width * 0.63, y: height * 0.08),
            control2: CGPoint(x: width * 0.65, y: height * 0.15)
        )
        
        // Указательный палец
        path.addCurve(
            to: CGPoint(x: width * 0.75, y: height * 0.15),
            control1: CGPoint(x: width * 0.67, y: height * 0.18),
            control2: CGPoint(x: width * 0.72, y: height * 0.15)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.8, y: height * 0.25),
            control1: CGPoint(x: width * 0.78, y: height * 0.15),
            control2: CGPoint(x: width * 0.8, y: height * 0.2)
        )
        
        // Большой палец
        path.addCurve(
            to: CGPoint(x: width * 0.9, y: height * 0.4),
            control1: CGPoint(x: width * 0.85, y: height * 0.3),
            control2: CGPoint(x: width * 0.88, y: height * 0.35)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.85, y: height * 0.6),
            control1: CGPoint(x: width * 0.92, y: height * 0.45),
            control2: CGPoint(x: width * 0.9, y: height * 0.55)
        )
        
        // Правая сторона ладони
        path.addCurve(
            to: CGPoint(x: width * 0.7, y: height * 0.8),
            control1: CGPoint(x: width * 0.8, y: height * 0.65),
            control2: CGPoint(x: width * 0.75, y: height * 0.75)
        )
        
        // Низ ладони
        path.addCurve(
            to: CGPoint(x: width * 0.2, y: height * 0.8),
            control1: CGPoint(x: width * 0.6, y: height * 0.85),
            control2: CGPoint(x: width * 0.3, y: height * 0.85)
        )
        
        return path
    }
}

// Индикатор уровня освещения
struct LightLevelIndicator: View {
    let lightLevel: Double
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(lightColor)
                .font(.system(size: 14))
            
            // Прогресс-бар освещенности
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 100, height: 6)
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(lightColor)
                    .frame(width: max(4, 100 * lightLevel), height: 6)
            }
            
            Text(lightLevelText)
                .font(.caption)
                .foregroundColor(.white)
                .shadow(color: .black, radius: 1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.4))
        .cornerRadius(12)
    }
    
    private var lightColor: Color {
        if lightLevel < 0.3 {
            return .red
        } else if lightLevel < 0.4 {
            return .orange
        } else if lightLevel > 0.85 {
            return .yellow
        } else {
            return .green
        }
    }
    
    private var lightLevelText: String {
        if lightLevel < 0.3 {
            return "Темно"
        } else if lightLevel < 0.4 {
            return "Тускло"
        } else if lightLevel > 0.85 {
            return "Ярко"
        } else {
            return "Хорошо"
        }
    }
}
