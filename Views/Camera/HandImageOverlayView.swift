import SwiftUI
import UIKit

struct HandImageOverlayView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                Image("hand_outline")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .blendMode(.destinationOut)
                
                Image("hand_outline")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .colorMultiply(.white)
                    .opacity(0.8)
                
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





struct HandSVGOverlayView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                
                HandOutlineShape()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .blendMode(.destinationOut)
                
                HandOutlineShape()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.8)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
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

struct HandOutlineShape: Shape {
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        
        var path = Path()
        
        path.move(to: CGPoint(x: width * 0.25, y: height * 0.85))
        
        path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.4))
        
        path.addLine(to: CGPoint(x: width * 0.15, y: height * 0.25))
        path.addLine(to: CGPoint(x: width * 0.25, y: height * 0.15))
        path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.25))
        
        path.addLine(to: CGPoint(x: width * 0.35, y: height * 0.1))
        path.addLine(to: CGPoint(x: width * 0.45, y: height * 0.2))
        
        path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.05))
        path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.15))
        
        path.addLine(to: CGPoint(x: width * 0.65, y: height * 0.1))
        path.addLine(to: CGPoint(x: width * 0.75, y: height * 0.2))
        
        path.addLine(to: CGPoint(x: width * 0.9, y: height * 0.4))
        path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.6))
        
        path.addLine(to: CGPoint(x: width * 0.75, y: height * 0.85))
        
        path.addLine(to: CGPoint(x: width * 0.25, y: height * 0.85))
        
        return path
    }
}
