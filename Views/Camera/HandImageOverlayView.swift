import SwiftUI
import UIKit

// MARK: - Улучшенный контур руки с использованием вашего изображения
struct HandImageOverlayView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Затемнение фона вокруг области руки
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                // Используем ваш контур руки как изображение
                // Вариант 1: Если вы добавите изображение в Assets.xcassets
                Image("hand_outline")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .blendMode(.destinationOut)
                
                // Дублируем контур с обычной прозрачностью, чтобы он был виден
                Image("hand_outline")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .colorMultiply(.white)
                    .opacity(0.8)
                
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

// MARK: - Вариант с SVG-контуром (на случай, если изображение не подойдет)
struct HandSVGOverlayView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Затемнение фона вокруг области руки
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                // Используем кастомный контур руки
                HandOutlineShape()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .blendMode(.destinationOut)
                
                // Дублируем контур, чтобы он был виден
                HandOutlineShape()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
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

// Shape, которая воссоздает примерный контур вашей руки
struct HandOutlineShape: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        
        var path = Path()
        
        // Начальная точка - низ ладони с левой стороны
        path.move(to: CGPoint(x: width * 0.25, y: height * 0.85))
        
        // Левая сторона ладони до основания мизинца
        path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.4))
        
        // Мизинец
        path.addLine(to: CGPoint(x: width * 0.15, y: height * 0.25))
        path.addLine(to: CGPoint(x: width * 0.25, y: height * 0.15))
        path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.25))
        
        // Безымянный палец
        path.addLine(to: CGPoint(x: width * 0.35, y: height * 0.1))
        path.addLine(to: CGPoint(x: width * 0.45, y: height * 0.2))
        
        // Средний палец
        path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.05))
        path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.15))
        
        // Указательный палец
        path.addLine(to: CGPoint(x: width * 0.65, y: height * 0.1))
        path.addLine(to: CGPoint(x: width * 0.75, y: height * 0.2))
        
        // Большой палец
        path.addLine(to: CGPoint(x: width * 0.9, y: height * 0.4))
        path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.6))
        
        // Правая сторона ладони
        path.addLine(to: CGPoint(x: width * 0.75, y: height * 0.85))
        
        // Замыкаем путь
        path.addLine(to: CGPoint(x: width * 0.25, y: height * 0.85))
        
        return path
    }
}

// MARK: - Инструкции по добавлению вашего изображения
/*
 Чтобы использовать ваш контур руки, выполните следующие шаги:
 
 1. Добавьте ваше изображение контура руки в проект:
    - Откройте Assets.xcassets
    - Создайте новый Image Set (правая кнопка мыши -> New Image Set)
    - Назовите его "hand_outline"
    - Перетащите ваш файл изображения в соответствующий слот
 
 2. Изображение должно быть контуром руки с прозрачным фоном (PNG)
 
 3. Замените в CameraView.swift компонент HandShapeOverlayView на HandImageOverlayView:
 
 ZStack {
     CameraPreviewView(session: viewModel.session)
         .frame(maxWidth: .infinity, maxHeight: .infinity)
         .cornerRadius(12)
         .overlay(
             RoundedRectangle(cornerRadius: 12)
                 .stroke(Color.white, lineWidth: 1)
         )
         .padding(.horizontal, 20)
     
     // Заменить эту строку:
     // HandShapeOverlayView()
     // на:
     HandImageOverlayView()
         .frame(maxWidth: .infinity, maxHeight: .infinity)
         .padding(.horizontal, 20)
     
     // ...остальной код...
 }
 
 4. Если изображение не подходит, используйте HandSVGOverlayView и настройте
    HandOutlineShape под точный контур вашего изображения.
 */
