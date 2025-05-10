import SwiftUI

struct DesignDetailView: View {
    var design: NailDesign
    
    @State private var isFavorite = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Изображение дизайна
                AsyncImage(url: URL(string: design.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                    @unknown default:
                        EmptyView()
                    }
                }
                
                // Название дизайна
                Text(design.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // Характеристики дизайна
                VStack(spacing: 12) {
                    CharacteristicRow(title: "Форма", value: design.shape)
                    CharacteristicRow(title: "Длина", value: design.length)
                    
                    if let occasion = design.occasion {
                        CharacteristicRow(title: "Мероприятие", value: occasion)
                    }
                    
                    if let season = design.season {
                        CharacteristicRow(title: "Сезон", value: season)
                    }
                    
                    CharacteristicRow(title: "Цвет", value: design.color)
                    
                    if let decoration = design.decoration {
                        CharacteristicRow(title: "Декор", value: decoration)
                    }
                    
                    if let material = design.material {
                        CharacteristicRow(title: "Материал", value: material)
                    }
                    
                    // Теги
                    if let tags = design.tags, !tags.isEmpty {
                        CharacteristicRow(title: "Теги", value: tags.joined(separator: ", "))
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Кнопки действий
                VStack(spacing: 15) {
                    // Кнопка для примерки
                    NavigationLink(destination: ARTryOnView(selectedDesign: design)) {
                        HStack {
                            Image(systemName: "camera.viewfinder")
                            Text("Примерить дизайн")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    // Кнопка добавления в избранное
                    if UserProfile.isLoggedIn {
                        Button(action: toggleFavorite) {
                            HStack {
                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                Text(isFavorite ? "Удалить из избранного" : "Добавить в избранное")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFavorite ? Color.red : Color(.systemGray5))
                            .foregroundColor(isFavorite ? .white : .primary)
                            .cornerRadius(10)
                        }
                    }
                    
                    // Кнопка поделиться
                    Button(action: shareDesign) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Поделиться")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationBarTitle("Детали дизайна", displayMode: .inline)
        .onAppear {
            checkFavoriteStatus()
        }
    }
    
    // Проверка статуса в избранном
    private func checkFavoriteStatus() {
        if let user = UserProfile.current {
            isFavorite = user.favoriteDesigns.contains(design.id)
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
    
    // Поделиться дизайном
    private func shareDesign() {
        // Создаем текст для шаринга
        let text = "Посмотри этот крутой дизайн маникюра: \(design.name)"
        
        // Проверяем, есть ли URL изображения
        if let url = URL(string: design.imageUrl) {
            // Загружаем изображение для шаринга
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        // Создаем Activity View Controller с текстом и изображением
                        let items: [Any] = [text, image]
                        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
                        
                        // Находим корневой контроллер для отображения
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootViewController = windowScene.windows.first?.rootViewController {
                            rootViewController.present(activityViewController, animated: true)
                        }
                    }
                } else {
                    // Если не удалось загрузить изображение, шарим только текст
                    DispatchQueue.main.async {
                        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                        
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootViewController = windowScene.windows.first?.rootViewController {
                            rootViewController.present(activityViewController, animated: true)
                        }
                    }
                }
            }.resume()
        } else {
            // Если нет URL, шарим только текст
            let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityViewController, animated: true)
            }
        }
    }
}

// Строка с характеристикой
struct CharacteristicRow: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.body)
        }
    }
}
