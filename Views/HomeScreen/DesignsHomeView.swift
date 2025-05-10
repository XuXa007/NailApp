// DesignsHomeView.swift
import SwiftUI

struct DesignsHomeView: View {
    @State private var designs: [NailDesign] = []
    @State private var isLoading = true
    @State private var showFilters = false
    @State private var filters = DesignFilters()
    
    var body: some View {
        ZStack {
            // Фон - светлый нейтральный
            Color(.systemGray6).edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Верхняя панель с заголовком и кнопкой фильтра
                HStack {
                    Text("Дизайны маникюра")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: {
                        showFilters = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 15)
                
                // Индикатор активных фильтров (если они есть)
                if hasActiveFilters() {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(activeFilters(), id: \.self) { filter in
                                Text(filter)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.pink.opacity(0.2))
                                    .foregroundColor(.pink)
                                    .cornerRadius(15)
                            }
                            
                            Button(action: {
                                resetFilters()
                            }) {
                                Text("Сбросить")
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundColor(.gray)
                                    .cornerRadius(15)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 10)
                }
                
                if isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Загрузка дизайнов...")
                        .foregroundColor(.gray)
                        .padding(.top)
                    Spacer()
                } else if designs.isEmpty {
                    Spacer()
                    VStack(spacing: 15) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Нет дизайнов по вашим критериям")
                            .font(.headline)
                        Text("Попробуйте изменить параметры фильтрации")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Button(action: {
                            showFilters = true
                        }) {
                            Text("Изменить фильтры")
                                .font(.headline)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 30)
                                .background(Color.pink)
                                .foregroundColor(.white)
                                .cornerRadius(25)
                                .shadow(color: Color.pink.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.top, 10)
                    }
                    Spacer()
                } else {
                    // Сетка дизайнов
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            ForEach(designs) { design in
                                ModernDesignCard(design: design)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 5)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .onAppear(perform: loadDesigns)
        .sheet(isPresented: $showFilters) {
            ModernFilterView(filters: $filters, onApply: {
                loadDesigns()
            })
            .presentationDetents([.medium, .large])
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
    
    // Проверка, есть ли активные фильтры
    private func hasActiveFilters() -> Bool {
        return filters.shape != nil || filters.length != nil ||
               filters.occasion != nil || filters.season != nil ||
               filters.color != nil || filters.decoration != nil ||
               filters.material != nil
    }
    
    // Получение списка активных фильтров для отображения
    private func activeFilters() -> [String] {
        var result: [String] = []
        
        if let shape = filters.shape { result.append(shape) }
        if let length = filters.length { result.append(length) }
        if let occasion = filters.occasion { result.append(occasion) }
        if let season = filters.season { result.append(season) }
        if let color = filters.color { result.append(color) }
        if let decoration = filters.decoration { result.append(decoration) }
        if let material = filters.material { result.append(material) }
        
        return result
    }
    
    // Сброс всех фильтров
    private func resetFilters() {
        filters = DesignFilters()
        loadDesigns()
    }
    
    // Загрузка дизайнов
    private func loadDesigns() {
        isLoading = true
        
        ApiService.shared.getDesigns(filters: filters) { designs, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let designs = designs {
                    self.designs = designs
                } else {
                    print("Ошибка загрузки дизайнов: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
}

// Современная карточка дизайна
struct ModernDesignCard: View {
    var design: NailDesign
    @State private var isFavorite = false
    
    var body: some View {
        NavigationLink(destination: DesignDetailView(design: design)) {
            VStack(alignment: .leading, spacing: 10) {
                // Изображение дизайна
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: design.imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 200)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                        case .failure:
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                                .frame(height: 200)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .cornerRadius(15)
                    
                    // Кнопка избранного
                    if UserProfile.isLoggedIn {
                        Button(action: toggleFavorite) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 18))
                                .foregroundColor(isFavorite ? .pink : .white)
                                .padding(8)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .padding(10)
                    }
                }
                
                // Информация о дизайне
                Text(design.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack {
                    Text(design.shape)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(design.color)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            // Проверяем, находится ли дизайн в избранном
            if let favoriteDesigns = UserProfile.current?.favoriteDesigns {
                isFavorite = favoriteDesigns.contains(design.id)
            }
        }
    }
    
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
