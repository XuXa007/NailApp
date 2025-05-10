import SwiftUI

struct FavoritesView: View {
    @State private var favorites: [NailDesign] = []
    @State private var isLoading: Bool = true
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Заголовок
                Text("Избранные дизайны")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                if isLoading {
                    // Индикатор загрузки
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                            .padding()
                        
                        Text("Загрузка...")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 50)
                } else if showError {
                    // Сообщение об ошибке
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .foregroundColor(.orange)
                            .padding()
                        
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            loadFavorites()
                        }) {
                            Text("Повторить")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 10)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 50)
                } else if favorites.isEmpty {
                    // Нет избранных дизайнов
                    VStack {
                        Image(systemName: "heart.slash")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70, height: 70)
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("У вас пока нет избранных дизайнов")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Добавляйте дизайны в избранное, чтобы быстро находить их здесь")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        NavigationLink(destination: MainDesignView()) {
                            Text("Найти дизайны")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 10)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 50)
                } else {
                    // Отображаем избранные дизайны
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(favorites) { design in
                            FavoriteDesignCard(design: design, onRemove: {
                                removeFavorite(designId: design.id)
                            })
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            loadFavorites()
        }
        .navigationBarTitle("Избранное", displayMode: .inline)
    }
    
    // Загрузка избранных дизайнов
    private func loadFavorites() {
        isLoading = true
        showError = false
        
        guard let user = UserProfile.current, !user.isGuest else {
            isLoading = false
            showError = true
            errorMessage = "Необходимо войти в систему для доступа к избранному"
            return
        }
        
        if user.favoriteDesigns.isEmpty {
            isLoading = false
            favorites = []
            return
        }
        
        // В демо-режиме используем фиктивные данные
#if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
            // Фильтруем демо-дизайны, чтобы показать только те, которые в избранном
            favorites = NailDesign.demoDesigns().filter { user.favoriteDesigns.contains($0.id) }
        }
        return
#endif
        
        // Здесь должен быть запрос к API для получения дизайнов по их ID
        // Для простоты пока используем локальные данные
    }
    
    // Удаление дизайна из избранного
    private func removeFavorite(designId: Int) {
        ApiService.shared.removeFromFavorites(designId: designId) { success, error in
            if success {
                // Обновляем список избранного
                if let user = UserProfile.current {
                    favorites.removeAll { $0.id == designId }
                }
            }
        }
    }
}

// Карточка избранного дизайна
struct FavoriteDesignCard: View {
    var design: NailDesign
    var onRemove: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            // Изображение дизайна
            AsyncImage(url: URL(string: design.imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(height: 150)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipped()
                case .failure:
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                        .frame(height: 150)
                @unknown default:
                    EmptyView()
                }
            }
            .cornerRadius(12)
            
            // Название дизайна
            Text(design.name)
                .font(.headline)
                .lineLimit(1)
                .padding(.top, 5)
            
            // Характеристики дизайна
            HStack {
                Text(design.shape)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(design.color)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Кнопки действий
            HStack {
                // Удалить из избранного
                Button(action: onRemove) {
                    Image(systemName: "heart.slash.fill")
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                // Перейти к детальной информации
                NavigationLink(destination: DesignDetailView(design: design)) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }
                
                // Примерить дизайн
                NavigationLink(destination: ARTryOnView(selectedDesign: design)) {
                    Image(systemName: "camera.viewfinder")
                        .foregroundColor(.green)
                }
            }
            .padding(.top, 5)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}
