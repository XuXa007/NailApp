import SwiftUI

struct FilterView: View {
    
    @Binding var filters: DesignFilters
    var onApply: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    // Локальные копии для редактирования
    @State private var selectedShape: String?
    @State private var selectedLength: String?
    @State private var selectedOccasion: String?
    @State private var selectedSeason: String?
    @State private var selectedColor: String?
    @State private var selectedDecoration: String?
    @State private var selectedMaterial: String?
    
    // Выбранная категория фильтра
    @State private var selectedCategory: FilterCategory = .shape
    
    // Категории фильтров
    enum FilterCategory: String, CaseIterable {
        case shape = "Форма"
        case length = "Длина"
        case occasion = "Мероприятие"
        case season = "Сезон"
        case color = "Цвет"
        case decoration = "Декор"
        case material = "Материал"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок
            HStack {
                Text("Фильтры")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            // Полоса для перетаскивания (драг-индикатор)
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.bottom, 10)
            
            // Вкладки категорий
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(FilterCategory.allCases, id: \.self) { category in
                        FilterCategoryButton(
                            title: category.rawValue,
                            isSelected: selectedCategory == category,
                            action: {
                                selectedCategory = category
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 10)
            
            // Контент в зависимости от выбранной категории
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    switch selectedCategory {
                    case .shape:
                        ModernOptionGrid(
                            title: "Выберите форму",
                            options: DesignFilters.shapeOptions,
                            selectedOption: $selectedShape
                        )
                    case .length:
                        ModernOptionGrid(
                            title: "Выберите длину",
                            options: DesignFilters.lengthOptions,
                            selectedOption: $selectedLength
                        )
                    case .occasion:
                        ModernOptionGrid(
                            title: "Выберите мероприятие",
                            options: DesignFilters.occasionOptions,
                            selectedOption: $selectedOccasion
                        )
                    case .season:
                        ModernOptionGrid(
                            title: "Выберите сезон",
                            options: DesignFilters.seasonOptions,
                            selectedOption: $selectedSeason
                        )
                    case .color:
                        ModernColorGrid(selectedColor: $selectedColor)
                    case .decoration:
                        ModernOptionGrid(
                            title: "Выберите декор",
                            options: DesignFilters.decorationOptions,
                            selectedOption: $selectedDecoration
                        )
                    case .material:
                        ModernOptionGrid(
                            title: "Выберите материал",
                            options: DesignFilters.materialOptions,
                            selectedOption: $selectedMaterial
                        )
                    }
                }
                .padding()
            }
            
            Spacer()
            
            // Кнопки действий
            VStack(spacing: 10) {
                Button(action: applyFilters) {
                    Text("Применить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pink)
                        .cornerRadius(15)
                }
                
                Button(action: resetFilters) {
                    Text("Сбросить все")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .onAppear {
            // Инициализация локальных копий при открытии
            selectedShape = filters.shape
            selectedLength = filters.length
            selectedOccasion = filters.occasion
            selectedSeason = filters.season
            selectedColor = filters.color
            selectedDecoration = filters.decoration
            selectedMaterial = filters.material
        }
    }
    
    // Сброс всех фильтров
    private func resetFilters() {
        selectedShape = nil
        selectedLength = nil
        selectedOccasion = nil
        selectedSeason = nil
        selectedColor = nil
        selectedDecoration = nil
        selectedMaterial = nil
    }
    
    // Применение фильтров
    private func applyFilters() {
        // Обновляем значения фильтров
        filters.shape = selectedShape
        filters.length = selectedLength
        filters.occasion = selectedOccasion
        filters.season = selectedSeason
        filters.color = selectedColor
        filters.decoration = selectedDecoration
        filters.material = selectedMaterial
        
        // Вызываем обработчик
        onApply()
        
        // Закрываем лист
        presentationMode.wrappedValue.dismiss()
    }
}

// Кнопка категории фильтра
struct FilterCategoryButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(isSelected ? Color.pink.opacity(0.2) : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .pink : .primary)
                .cornerRadius(20)
        }
    }
}

// Современная сетка опций
struct ModernOptionGrid: View {
    var title: String
    var options: [String]
    @Binding var selectedOption: String?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(options, id: \.self) { option in
                    ModernOptionButton(
                        title: option,
                        isSelected: selectedOption == option,
                        action: {
                            if selectedOption == option {
                                selectedOption = nil
                            } else {
                                selectedOption = option
                            }
                        }
                    )
                }
            }
        }
    }
}

// Современная кнопка опции
struct ModernOptionButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.pink)
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(isSelected ? Color.pink.opacity(0.1) : Color.gray.opacity(0.05))
            .foregroundColor(isSelected ? .pink : .primary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.pink : Color.clear, lineWidth: 1)
            )
        }
    }
}

// Современная сетка цветов
struct ModernColorGrid: View {
    @Binding var selectedColor: String?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let colors = [
        ("Красный", Color.red),
        ("Розовый", Color.pink),
        ("Белый", Color.white),
        ("Черный", Color.black),
        ("Синий", Color.blue),
        ("Зеленый", Color.green),
        ("Желтый", Color.yellow),
        ("Фиолетовый", Color.purple),
        ("Нюдовый", Color(red: 0.98, green: 0.86, blue: 0.79))
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Выберите цвет")
                .font(.headline)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(colors, id: \.0) { colorName, colorValue in
                    ModernColorButton(
                        name: colorName,
                        color: colorValue,
                        isSelected: selectedColor == colorName,
                        action: {
                            if selectedColor == colorName {
                                selectedColor = nil
                            } else {
                                selectedColor = colorName
                            }
                        }
                    )
                }
            }
        }
    }
}

// Современная кнопка цвета
struct ModernColorButton: View {
    var name: String
    var color: Color
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: 60, height: 60)
                        .shadow(radius: 3)
                    
                    if isSelected {
                        Circle()
                            .strokeBorder(Color.pink, lineWidth: 3)
                            .frame(width: 66, height: 66)
                    }
                }
                
                Text(name)
                    .font(.caption)
                    .foregroundColor(isSelected ? .pink : .primary)
                    .lineLimit(1)
                    .padding(.top, 5)
            }
        }
    }
}
