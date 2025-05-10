import SwiftUI

struct DesignGridItem: View {
    var design: NailDesign
    var selectionMode: Bool
    var onSelect: () -> Void
    
    @State private var isFavorite: Bool = false
    
    var body: some View {
        VStack {
            // Изображение дизайна
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: design.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 180)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                            .frame(height: 180)
                    @unknown default:
                        EmptyView()
                    }
                }
                .cornerRadius(12)
                
                // Кнопка добавления в избранное
                if !selectionMode && UserProfile.isLoggedIn {
                    Button(action: toggleFavorite) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(isFavorite ? .red : .white)
                            .padding(8)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    .padding(8)
                }
            }
            
            // Информация о дизайне
            VStack(alignment: .leading, spacing: 4) {
                Text(design.name)
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text(design.shape)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(design.color)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 5)
            .padding(.vertical, 8)
            
            // Кнопки действий
            if selectionMode {
                Button(action: onSelect) {
                    Text("Выбрать")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .font(.subheadline)
                }
            } else {
                NavigationLink(destination: DesignDetailView(design: design)) {
                    Text("Подробнее")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .font(.subheadline)
                }
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onAppear {
            // Проверяем, находится ли дизайн в избранном
            if let favoriteDesigns = UserProfile.current?.favoriteDesigns {
                isFavorite = favoriteDesigns.contains(design.id)
            }
        }
    }
    
    // Переключение статуса избранного
    private func toggleFavorite() {
        if isFavorite {
            ApiService.shared.removeFromFavorites(designId: design.id) { success, _ in
                if success {
                    isFavorite = false
                }
            }
        } else {
            ApiService.shared.addToFavorites(designId: design.id) { success, _ in
                if success {
                    isFavorite = true
                }
            }
        }
    }
}
