import AVFoundation
import SwiftUI
import UIKit

// MARK: - Исправленное представление предпросмотра камеры
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.backgroundColor = .black
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        
        // Важное исправление: добавляем тег к слою предпросмотра для отладки
        view.videoPreviewLayer.name = "CameraPreviewLayer"
        
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
        // Отладочная информация
        print("CameraPreviewView обновлена с размерами: \(uiView.bounds.width) x \(uiView.bounds.height)")
    }
    
    // Класс для правильного управления слоем предпросмотра
    class PreviewView: UIView {
        override class var layerClass: AnyClass {
            return AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
}

// MARK: - Улучшенный контур руки
struct HandShapeOverlayView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Затемнение фона вокруг области руки
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                // Контур руки (вырез в затемнении)
                HandShape()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.7)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .blendMode(.destinationOut)
                
                // Дублируем контур, чтобы он был виден
                HandShape()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: geometry.size.width * 0.7, height: geometry.size.height * 0.7)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
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

// MARK: - Форма руки для контура
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
