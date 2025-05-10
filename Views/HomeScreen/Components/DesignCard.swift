import SwiftUI

struct DesignCard: View {
    var design: NailDesign
    
    var body: some View {
        VStack {
            // Изображение дизайна
            AsyncImage(url: URL(string: design.imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 150, height: 150)
            .cornerRadius(10)
            
            // Название дизайна
            Text(design.name)
                .font(.caption)
                .lineLimit(1)
                .padding(.top, 5)
        }
        .frame(width: 150)
    }
}
