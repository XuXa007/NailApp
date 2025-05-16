//class CameraViewModel: ObservableObject {
//    @Published var session = AVCaptureSession()
//    @Published var lightLevel: Double = 0.0
//    @Published var statusMessage: String?
//    @Published var statusIsWarning: Bool = false
//    
//    private var isConfigured = false
//    private var camera: AVCaptureDevice?
//    private var photoOutput = AVCapturePhotoOutput()
//    private var completionHandler: ((UIImage?) -> Void)?
//    private var captureQueue = DispatchQueue(label: "captureQueue")
//    private var lastLightMeasurement = Date()
//    private var lightnessTimer: Timer?
//    
//    func checkPermissionsAndStartSession() {
//        switch AVCaptureDevice.authorizationStatus(for: .video) {
//        case .authorized:
//            self.setupSession()
//        case .notDetermined:
//            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
//                guard let self = self else { return }
//                if granted {
//                    DispatchQueue.main.async {
//                        self.setupSession()
//                    }
//                } else {
//                    self.setError("Нет доступа к камере")
//                }
//            }
//        default:
//            self.setError("Нет доступа к камере")
//        }
//    }
//    
//    func setupSession() {
//        captureQueue.async { [weak self] in
//            guard let self = self else { return }
//            
//            guard !self.isConfigured else { return }
//            
//            self.session.beginConfiguration()
//            
//            guard let camera = self.getBestCamera() else {
//                self.setError("Не удалось инициализировать камеру")
//                return
//            }
//            
//            self.camera = camera
//            
//            do {
//                // Настраиваем вход
//                let input = try AVCaptureDeviceInput(device: camera)
//                
//                if self.session.canAddInput(input) {
//                    self.session.addInput(input)
//                } else {
//                    self.setError("Не удалось добавить вход камеры")
//                    self.session.commitConfiguration()
//                    return
//                }
//                
//                // Настраиваем выход
//                if self.session.canAddOutput(self.photoOutput) {
//                    self.session.addOutput(self.photoOutput)
//                } else {
//                    self.setError("Не удалось добавить выход для фото")
//                    self.session.commitConfiguration()
//                    return
//                }
//                
//                self.session.commitConfiguration()
//                self.isConfigured = true
//                
//                // Запускаем сессию
//                self.session.startRunning()
//                
//                // Запускаем таймер для измерения освещенности
//                DispatchQueue.main.async {
//                    self.startLightnessTimer()
//                }
//            } catch {
//                self.setError("Ошибка настройки камеры: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    func stopSession() {
//        captureQueue.async { [weak self] in
//            guard let self = self else { return }
//            
//            if self.session.isRunning {
//                self.session.stopRunning()
//            }
//            
//            DispatchQueue.main.async {
//                self.lightnessTimer?.invalidate()
//                self.lightnessTimer = nil
//            }
//        }
//    }
//    
//    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
//        guard session.isRunning else {
//            completion(nil)
//            return
//        }
//        
//        if lightLevel < 0.4 {
//            statusMessage = "Недостаточное освещение для хорошего фото"
//            statusIsWarning = true
//            
//            // Даем обратную связь через вибрацию
//            let generator = UINotificationFeedbackGenerator()
//            generator.notificationOccurred(.warning)
//            
//            // Продолжаем с захватом фото несмотря на предупреждение
//        } else {
//            statusMessage = "Захват фото..."
//            statusIsWarning = false
//        }
//        
//        self.completionHandler = completion
//        
//        let settings = AVCapturePhotoSettings()
//        
//        // Оптимизируем настройки для рук
//        settings.flashMode = .auto
//        
//        if let previewPhotoPixelFormatType = settings.availablePreviewPhotoPixelFormatTypes.first {
//            settings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPhotoPixelFormatType]
//        }
//        
//        photoOutput.capturePhoto(with: settings, delegate: self)
//    }
//    
//    func switchCamera() {
//        stopSession()
//        
//        // Ждем остановки сессии
//        captureQueue.async { [weak self] in
//            guard let self = self else { return }
//            
//            self.isConfigured = false
//            // Очищаем текущие входы/выходы
//            for input in self.session.inputs {
//                self.session.removeInput(input)
//            }
//            for output in self.session.outputs {
//                self.session.removeOutput(output)
//            }
//            
//            DispatchQueue.main.async {
//                self.setupSession()
//            }
//        }
//    }
//    
//    private func getBestCamera() -> AVCaptureDevice? {
//        // По умолчанию используем заднюю камеру (она обычно лучшего качества)
//        if let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
//            try? backCamera.lockForConfiguration()
//            // Настраиваем автофокус для руки (обычно на расстоянии 20-40 см)
//            if backCamera.isFocusModeSupported(.continuousAutoFocus) {
//                backCamera.focusMode = .continuousAutoFocus
//            }
//            backCamera.unlockForConfiguration()
//            return backCamera
//        }
//        
//        // Если задняя недоступна, используем переднюю
//        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
//    }
//    
//    private func startLightnessTimer() {
//        lightnessTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
//            self?.measureLightLevel()
//        }
//    }
//    
//    private func measureLightLevel() {
//        guard let camera = camera, Date().timeIntervalSince(lastLightMeasurement) > 0.2 else { return }
//        lastLightMeasurement = Date()
//        
//        do {
//            try camera.lockForConfiguration()
//            
//            // ISO и выдержка помогают оценить освещенность
//            let currentISO = camera.iso
//            let currentExposureDuration = camera.exposureDuration
//            
//            let maxISO = camera.activeFormat.maxISO
//            
//            // Если ISO близко к максимальному, вероятно, недостаточно света
//            // Если выдержка длинная, также недостаточно света
//            let normalizedISO = min(currentISO / maxISO, 1.0)
//            let exposureFactor = 1.0 - min(currentExposureDuration.seconds / 0.25, 1.0)
//            
//            let calculatedLightLevel = exposureFactor * (1.0 - normalizedISO)
//            
//            camera.unlockForConfiguration()
//            
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                
//                // Сглаживаем изменения, чтобы избежать резких скачков
//                self.lightLevel = self.lightLevel * 0.7 + calculatedLightLevel * 0.3
//                
//                // Обновляем сообщение в зависимости от уровня освещения
//                if self.lightLevel < 0.3 {
//                    self.statusMessage = "Слишком темно. Найдите более яркое освещение."
//                    self.statusIsWarning = true
//                } else if self.lightLevel < 0.4 {
//                    self.statusMessage = "Недостаточное освещение. Рекомендуется улучшить."
//                    self.statusIsWarning = true
//                } else if self.lightLevel > 0.85 {
//                    self.statusMessage = "Слишком яркое освещение. Избегайте прямого солнечного света."
//                    self.statusIsWarning = true
//                } else {
//                    self.statusMessage = "Хорошее освещение. Расположите руку в контуре."
//                    self.statusIsWarning = false
//                }
//            }
//            
//        } catch {
//            print("Ошибка измерения освещенности: \(error)")
//        }
//    }
//    
//    private func setError(_ message: String) {
//        DispatchQueue.main.async { [weak self] in
//            self?.statusMessage = message
//            self?.statusIsWarning = true
//        }
//    }
//}
//
//// Расширение для обработки захваченных фото
//extension CameraViewModel: AVCapturePhotoCaptureDelegate {
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        if let error = error {
//            setError("Ошибка при захвате фото: \(error.localizedDescription)")
//            completionHandler?(nil)
//            return
//        }
//        
//        guard let imageData = photo.fileDataRepresentation() else {
//            setError("Не удалось получить данные изображения")
//            completionHandler?(nil)
//            return
//        }
//        
//        guard let image = UIImage(data: imageData) else {
//            setError("Не удалось создать изображение из данных")
//            completionHandler?(nil)
//            return
//        }
//        
//        // Проверяем ориентацию и корректируем при необходимости
//        var finalImage = image
//        
//        // Уменьшаем изображение до оптимального размера для ML
//        finalImage = resizeImage(finalImage, maxDimension: Config.TryOn.maxImageDimension)
//        
//        DispatchQueue.main.async { [weak self] in
//            self?.statusMessage = nil
//            self?.completionHandler?(finalImage)
//        }
//    }
//    
//    private func resizeImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
//        let size = image.size
//        
//        // Если изображение уже меньше максимального размера, вернуть его как есть
//        if size.width <= maxDimension && size.height <= maxDimension {
//            return image
//        }
//        
//        // Вычисляем новые размеры, сохраняя соотношение сторон
//        var newWidth: CGFloat
//        var newHeight: CGFloat
//        
//        if size.width > size.height {
//            newWidth = maxDimension
//            newHeight = size.height * maxDimension / size.width
//        } else {
//            newHeight = maxDimension
//            newWidth = size.width * maxDimension / size.height
//        }
//        
//        let targetSize = CGSize(width: newWidth, height: newHeight)
//        
//        // Изменяем размер изображения
//        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
//        image.draw(in: CGRect(origin: .zero, size: targetSize))
//        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return resizedImage ?? image
//    }
//}
