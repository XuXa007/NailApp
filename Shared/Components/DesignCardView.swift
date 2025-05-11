import SwiftUI

struct DesignCardView: View {
    let design: NailDesign
    
    var body: some View {
        VStack(spacing: 0) {
            // изображение сверху
            if let url = design.imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.3)
                    case .success(let img):
                        img
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Color.red.opacity(0.3)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 120)
                .clipped()
                .mask(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .frame(height: 120)
                        .padding(.bottom, -16)
                )
            }
            
            // ьэкграунд
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.1))
                // сам текст
                Text(design.name)
                    .font(.subheadline).bold()
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
            }
            .frame(maxWidth: .infinity)
        }
        .overlay(
            // обводка
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .background(
            // фон контейнер
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.clear)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        .padding(4)
    }
}
