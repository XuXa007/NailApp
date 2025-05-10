import SwiftUI

struct MainDesignView: View {
    @State private var filters = DesignFilters()
    @State private var showFilters = false
    @State private var designs: [NailDesign] = []
    @State private var isLoading = true
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Флаг, указывающий, находимся ли мы в режиме выбора дизайна
    var selectionMode: Bool = false
    
    // Обработчик выбора дизайна (для режима выбора)
    var onSelect: ((NailDesign) -> Void)?
    
    var body: some View {
        VStack {
            // Заголовок
            HStack {
                Text(selectionMode ? "Выберите дизайн" : "Дизайны маникюра")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    showFilters = true
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.primary)
                }
            }
            .padding()
            
            // Горизонтальный скролл с фильтрами
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    FilterChip(title: "Форма", value: filters.shape) {
                        showFilters = true
                    }
                    
                    FilterChip(title: "Длина", value: filters.length) {
                        showFilters = true
                    }
                    
                    FilterChip(title: "Мероприятие", value: filters.occasion) {
                        showFilters = true
                    }
                    
                    FilterChip(title: "Сезон", value: filters.season) {
                        showFilters = true
                    }
                    
                    FilterChip(title: "Цвет", value: filters.color) {
                        showFilters = true
                    }
                }
                .padding(.horizontal)
            }
            
            if isLoading {
                // Индикатор загрузки
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                Text("Загрузка дизайнов...")
                    .foregroundColor(.gray)
                    .padding(.top)
                Spacer()
            } else if showError {
                // Сообщение об ошибке
                Spacer()
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text(errorMessage)
                        .multilineTextAlignment(.center)
                    
                    Button(action: loadDesigns) {
                        Text("Повторить")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                Spacer()
            } else if designs.isEmpty {
                // Нет найденных дизайнов
                Spacer()
                VStack(spacing: 20) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("Дизайны не найдены")
                        .font(.headline)
                    
                    Text("Попробуйте изменить параметры фильтрации")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        showFilters = true
                    }) {
                        Text("Изменить фильтры")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
                Spacer()
            } else {
                // Список дизайнов
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(designs) { design in
                            DesignGridItem(
                                design: design,
                                selectionMode: selectionMode,
                                onSelect: {
                                    if selectionMode, let onSelect = onSelect {
                                        onSelect(design)
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear(perform: loadDesigns)
        .sheet(isPresented: $showFilters) {
            FilterView(filters: $filters, onApply: {
                loadDesigns()
            })
        }
        .navigationBarTitle("Дизайны", displayMode: .inline)
    }
    
    // Загрузка дизайнов
    private func loadDesigns() {
        isLoading = true
        showError = false
        
        ApiService.shared.getDesigns(filters: filters) { designs, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let designs = designs {
                    self.designs = designs
                } else {
                    showError = true
                    errorMessage = error?.localizedDescription ?? "Ошибка загрузки дизайнов"
                }
            }
        }
    }
}

// Компонент фильтра
struct FilterChip: View {
    var title: String
    var value: String?
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.subheadline)
                
                if let value = value {
                    Text(value)
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.blue, lineWidth: value != nil ? 2 : 1)
                    .background(
                        value != nil ? Color.blue.opacity(0.1) : Color(.systemBackground)
                    )
                    .cornerRadius(20)
            )
        }
    }
}
