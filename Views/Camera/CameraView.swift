import SwiftUI
import AVFoundation

struct CameraView: View {
    @ObservedObject var viewModel = CameraViewModel()
    @Environment(\.presentationMode) var presentationMode
    @Binding var capturedImage: UIImage?
    
    var body: some View {
        ZStack {
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
                    CameraPreviewView(session: viewModel.session)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                    
                    // Добавляем контур руки
                    HandImageOverlayView()
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
                        // Обновленный вызов без координатора
                        viewModel.capturePhoto { image in
                            if let image = image {
                                self.capturedImage = image
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
            // Важное исправление: принудительно перезапускаем сессию камеры при появлении экрана
            viewModel.stopSession()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                viewModel.checkPermissionsAndStartSession()
            }
        }
        .onDisappear {
            viewModel.stopSession()
        }
    }
}

// Представление предпросмотра камеры
//struct CameraPreviewView: UIViewRepresentable {
//    let session: AVCaptureSession
//    
//    func makeUIView(context: Context) -> UIView {
//        let view = PreviewView()
//        view.backgroundColor = .black
//        view.videoPreviewLayer.session = session
//        view.videoPreviewLayer.videoGravity = .resizeAspectFill
//        
//        return view
//    }
//    
//    func updateUIView(_ uiView: UIView, context: Context) {
//        if let previewView = uiView as? PreviewView {
//            previewView.videoPreviewLayer.frame = uiView.bounds
//        }
//    }
//    
//    // Класс для правильного создания слоя превью
//    class PreviewView: UIView {
//        override class var layerClass: AnyClass {
//            return AVCaptureVideoPreviewLayer.self
//        }
//        
//        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
//            return layer as! AVCaptureVideoPreviewLayer
//        }
//    }
//}

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
        } else if lightLevel > 0.7 {
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
