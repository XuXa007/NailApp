import SwiftUI
import AVFoundation
import UIKit

// Основная структура для интеграции с SwiftUI
struct CameraView: View {
    @StateObject private var viewModel = CameraViewModel()
    @Environment(\.presentationMode) var presentationMode
    @Binding var capturedImage: UIImage?
    
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
                
                ZStack {
                    // Превью камеры
                    CameraPreviewView(session: viewModel.session)
                        .aspectRatio(4/3, contentMode: .fit)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white, lineWidth: 1)
                        )
                        .padding(20)
                    
                    // Направляющие для руки
                    HandOverlayView()
                        .aspectRatio(4/3, contentMode: .fit)
                        .padding(20)
                    
                    // Индикатор освещения
                    VStack {
                        Spacer()
                        LightLevelIndicator(lightLevel: viewModel.lightLevel)
                            .padding(.bottom, 10)
                    }
                }
                
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
                        viewModel.capturePhoto { image in
                            if let image = image {
                                capturedImage = image
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
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

// Модель представления для обработки логики камеры
class CameraViewModel: ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var lightLevel: Double = 0.0
    @Published var statusMessage: String?
    @Published var statusIsWarning: Bool = false
    
    private var isConfigured = false
    private var camera: AVCaptureDevice?
    private var photoOutput = AVCapturePhotoOutput()
    private var completionHandler: ((UIImage?) -> Void)?
    private var captureQueue = DispatchQueue(label: "captureQueue")
    private var lastLightMeasurement = Date()
    private var lightnessTimer: Timer?
    
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
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        guard session.isRunning else {
            completion(nil)
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
        
        self.completionHandler = completion
        
        let settings = AVCapturePhotoSettings()
        
        // Оптимизируем настройки для рук
        settings.flashMode = .auto
        
        if let previewPhotoPixelFormatType = settings.availablePreviewPhotoPixelFormatTypes.first {
            settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
        }
        
        photoOutput.capturePhoto(with: settings, delegate: self)
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
            try? backCamera.lockForConfiguration()
            // Настраиваем автофокус для руки (обычно на расстоянии 20-40 см)
            if backCamera.isFocusModeSupported(.continuousAutoFocus) {
                backCamera.focusMode = .continuousAutoFocus
            }
            backCamera.unlockForConfiguration()
            return backCamera
        }
        
        // Если задняя недоступна, используем переднюю
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    }
    
    private func startLightnessTimer() {
        lightnessTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.measureLightLevel()
        }
    }
    
    private func measureLightLevel() {
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
            
            let calculatedLightLevel = exposureFactor * (1.0 - normalizedISO)
            
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
    
    private func setError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.statusMessage = message
            self?.statusIsWarning = true
        }
    }
}

// Расширение для обработки захваченных фото
extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            setError("Ошибка при захвате фото: \(error.localizedDescription)")
            completionHandler?(nil)
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            setError("Не удалось получить данные изображения")
            completionHandler?(nil)
            return
        }
        
        guard let image = UIImage(data: imageData) else {
            setError("Не удалось создать изображение из данных")
            completionHandler?(nil)
            return
        }
        
        // Проверяем ориентацию и корректируем при необходимости
        var finalImage = image
        
        // Уменьшаем изображение до оптимального размера для ML
        finalImage = resizeImage(finalImage, maxDimension: Config.TryOn.maxImageDimension)
        
        DispatchQueue.main.async { [weak self] in
            self?.statusMessage = nil
            self?.completionHandler?(finalImage)
        }
    }
    
    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
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
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}

// Направляющие для руки
struct HandOverlayView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Затемнение по краям для большего внимания на центр
                Path { path in
                    path.addRect(CGRect(x: 0, y: 0, width: geometry.size.width, height: geometry.size.height))
                    
                    // Вырезаем овал для руки в центре (примерно 70-80% площади)
                    let handWidth = geometry.size.width * 0.8
                    let handHeight = geometry.size.height * 0.7
                    let handX = (geometry.size.width - handWidth) / 2
                    let handY = (geometry.size.height - handHeight) / 2
                    path.addEllipse(in: CGRect(x: handX, y: handY, width: handWidth, height: handHeight))
                }
                .fill(
                    Color.black.opacity(0.3)
                )
                .blendMode(.darken)
                
                // Контур для руки
                Ellipse()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.7)
                
                // Маркеры для пальцев
                VStack {
                    Spacer()
                    HStack {
                        ForEach(0..<5) { _ in
                            Circle()
                                .fill(Color.white.opacity(0.5))
                                .frame(width: 8, height: 8)
                            Spacer()
                        }
                    }
                    .padding(.horizontal, geometry.size.width * 0.2)
                    .padding(.bottom, geometry.size.height * 0.25)
                }
                
                // Текст с инструкцией
                VStack {
                    Text("Расположите руку в центре")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 0, y: 0)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(4)
                    Spacer()
                }
                .padding(.top, 20)
            }
        }
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
