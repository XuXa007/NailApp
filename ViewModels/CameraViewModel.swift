import Foundation
import AVFoundation
import UIKit

class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
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
    private var photoCompletion: ((UIImage?) -> Void)?
    
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
        // Важное исправление: выполняем настройку в главном потоке
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            guard !self.isConfigured else { return }
            
            // Очищаем текущую сессию
            self.session.beginConfiguration()
            
            for input in self.session.inputs {
                self.session.removeInput(input)
            }
            
            for output in self.session.outputs {
                self.session.removeOutput(output)
            }
            
            // Установка высокого разрешения для качественного изображения
            self.session.sessionPreset = .high
            
            guard let camera = self.getBestCamera() else {
                self.setError("Не удалось инициализировать камеру")
                self.session.commitConfiguration()
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
                
                // Отладочное сообщение
                print("Сессия камеры настроена и готова к запуску")
                
                // Запускаем сессию асинхронно
                self.captureQueue.async {
                    if !self.session.isRunning {
                        self.session.startRunning()
                        print("Сессия камеры запущена")
                    }
                }
                
                // Запускаем таймер для измерения освещенности
                self.startLightnessTimer()
            } catch {
                self.setError("Ошибка настройки камеры: \(error.localizedDescription)")
                print("Ошибка настройки камеры: \(error)")
            }
        }
    }
    
    func stopSession() {
        captureQueue.async { [weak self] in
            guard let self = self else { return }
            
            if self.session.isRunning {
                self.session.stopRunning()
                print("Сессия камеры остановлена")
            }
            
            DispatchQueue.main.async {
                self.lightnessTimer?.invalidate()
                self.lightnessTimer = nil
                // Сбрасываем флаг сконфигурированной сессии для возможности повторной настройки
                self.isConfigured = false
            }
        }
    }
    
    // ИСПРАВЛЕННЫЙ МЕТОД: теперь принимает замыкание вместо координатора
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
        
        // Сохраняем замыкание для использования в делегате
        self.photoCompletion = completion
        
        let settings = AVCapturePhotoSettings()
        
        // Оптимизируем настройки для рук
        settings.flashMode = .auto
        
        if let previewPhotoPixelFormatType = settings.availablePreviewPhotoPixelFormatTypes.first {
            settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
        }
        
        print("Захват фото начат")
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // Метод делегата AVCapturePhotoCaptureDelegate для обработки захваченного фото
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            setError("Ошибка при захвате фото: \(error.localizedDescription)")
            photoCompletion?(nil)
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else {
            setError("Не удалось получить данные изображения")
            photoCompletion?(nil)
            return
        }
        
        guard let image = UIImage(data: imageData) else {
            setError("Не удалось создать изображение из данных")
            photoCompletion?(nil)
            return
        }
        
        // Проверяем ориентацию и корректируем при необходимости
        var finalImage = image
        
        // Уменьшаем изображение до оптимального размера для ML
        finalImage = resizeImage(image: finalImage, maxDimension: 1200) // Использовать фиксированное значение, если Config недоступен
        
        DispatchQueue.main.async { [weak self] in
            self?.statusMessage = nil
            self?.photoCompletion?(finalImage)
        }
    }
    
    func switchCamera() {
        stopSession()
        
        // Ждем остановки сессии
        captureQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.isConfigured = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.setupSession()
            }
        }
    }
    
    private func getBestCamera() -> AVCaptureDevice? {
        // Проверяем доступность задней камеры
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
        } else {
            print("Задняя камера недоступна")
        }
        
        // Если задняя недоступна, используем переднюю
        if let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            print("Используем переднюю камеру")
            return frontCamera
        }
        
        print("Не найдено доступных камер")
        return nil
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
            print("Ошибка камеры: \(message)")
        }
    }
    
    // Метод для изменения размера изображения
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
}
