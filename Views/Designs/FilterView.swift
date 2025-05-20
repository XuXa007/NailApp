import SwiftUI

struct FilterView: View {
    @ObservedObject var vm: FilterViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var activeTab: FilterTab = .colors
    
    enum FilterTab {
        case colors, styles, seasons, types
        
        var title: String {
            switch self {
            case .colors: return "Цвет"
            case .styles: return "Стиль"
            case .seasons: return "Сезон"
            case .types: return "Тип"
            }
        }
        
        var icon: String {
            switch self {
            case .colors: return "circle.grid.2x2.fill"
            case .styles: return "paintbrush.fill"
            case .seasons: return "leaf.fill"
            case .types: return "square.on.square.fill"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.5), Color.blue.opacity(0.5)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Capsule()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 40, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                    
                    tabsView
                        .padding(.horizontal)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            switch activeTab {
                            case .colors:
                                colorFiltersView
                            case .styles:
                                styleFiltersView
                            case .seasons:
                                seasonFiltersView
                            case .types:
                                typeFiltersView
                            }
                        }
                        .padding()
                    }
                    
                    actionButtonsView
                }
            }
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                        .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Готово") {
                        vm.apply()
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    

    private var tabsView: some View {
        HStack(spacing: 0) {
            ForEach([FilterTab.colors, .styles, .seasons, .types], id: \.self) { tab in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        activeTab = tab
                    }
                }) {
                    VStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16))
                        
                        Text(tab.title)
                            .font(.caption)
                            .lineLimit(1)
                        
                        Capsule()
                            .fill(activeTab == tab ? Color.white : Color.clear)
                            .frame(height: 3)
                    }
                    .foregroundColor(activeTab == tab ? .white : .white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.2))
        )
    }
    
    private var colorFiltersView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Выберите цвета")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if !vm.filter.selectedColors.isEmpty {
                    Text("\(vm.filter.selectedColors.count) выбрано")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 70), spacing: 15)], spacing: 15) {
                ForEach(vm.availableColors) { color in
                    let isSelected = vm.filter.selectedColors.contains(color)
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if isSelected {
                                vm.filter.selectedColors.remove(color)
                            } else {
                                vm.filter.selectedColors.insert(color)
                            }
                        }
                    }) {
                        VStack(spacing: 8) {
                            Circle()
                                .fill(color.color)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                                        .padding(2)
                                )
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                        .opacity(isSelected ? 1 : 0)
                                )
                                .shadow(color: color.color.opacity(0.5), radius: 5, x: 0, y: 2)
                            
                            Text(color.description)
                                .font(.caption)
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .multilineTextAlignment(.center)
                        }
                    }
                }
            }
            .padding(.top, 8)
        }
    }
    
    private var styleFiltersView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Выберите стили")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if !vm.filter.selectedStyles.isEmpty {
                    Text("\(vm.filter.selectedStyles.count) выбрано")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                ForEach(vm.availableStyles) { style in
                    let isSelected = vm.filter.selectedStyles.contains(style)
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if isSelected {
                                vm.filter.selectedStyles.remove(style)
                            } else {
                                vm.filter.selectedStyles.insert(style)
                            }
                        }
                    }) {
                        HStack(spacing: 12) {
                            styleIconFor(style)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                            
                            Text(style.description)
                                .foregroundColor(.white)
                                .fontWeight(isSelected ? .semibold : .regular)
                            
                            Spacer()
                            
                            if isSelected {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(styleGradientFor(style, isSelected: isSelected))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(isSelected ? 0.4 : 0.2), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
    
    private var seasonFiltersView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Выберите сезоны")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if !vm.filter.selectedSeasons.isEmpty {
                    Text("\(vm.filter.selectedSeasons.count) выбрано")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 15)], spacing: 15) {
                ForEach(vm.availableSeasons) { season in
                    let isSelected = vm.filter.selectedSeasons.contains(season)
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if isSelected {
                                vm.filter.selectedSeasons.remove(season)
                            } else {
                                vm.filter.selectedSeasons.insert(season)
                            }
                        }
                    }) {
                        VStack(spacing: 0) {
                            ZStack {
                                seasonBackgroundFor(season)
                                    .frame(height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                
                                seasonIconFor(season)
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                                        .padding(6)
                                        .background(Color.black.opacity(0.3))
                                        .clipShape(Circle())
                                        .position(x: 130, y: 20)
                                }
                            }
                            
                            Text(season.description)
                                .font(.subheadline)
                                .fontWeight(isSelected ? .semibold : .regular)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(seasonColorFor(season).opacity(isSelected ? 0.8 : 0.5))
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white.opacity(isSelected ? 0.6 : 0.2), lineWidth: isSelected ? 2 : 0.5)
                        )
                        .shadow(color: seasonColorFor(season).opacity(isSelected ? 0.5 : 0.2), radius: isSelected ? 10 : 4, x: 0, y: isSelected ? 4 : 2)
                    }
                }
            }
        }
    }
    
    private var typeFiltersView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Выберите типы дизайна")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if !vm.filter.selectedTypes.isEmpty {
                    Text("\(vm.filter.selectedTypes.count) выбрано")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 15)], spacing: 15) {
                ForEach(vm.availableTypes) { type in
                    let isSelected = vm.filter.selectedTypes.contains(type)
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            if isSelected {
                                vm.filter.selectedTypes.remove(type)
                            } else {
                                vm.filter.selectedTypes.insert(type)
                            }
                        }
                    }) {
                        ZStack(alignment: .center) {
                            // Фон карточки
                            designTypeBackgroundFor(type)
                                .frame(width: 150, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.white.opacity(isSelected ? 0.6 : 0.2), lineWidth: isSelected ? 2 : 0.5)
                                )
                                .shadow(color: .black.opacity(isSelected ? 0.3 : 0.1), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
                            
                            VStack(spacing: 8) {
                                designTypeIconFor(type)
                                    .font(.system(size: 24))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                                
                                Text(type.description)
                                    .font(.headline)
                                    .fontWeight(isSelected ? .bold : .semibold)
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                            }
                            
                            if isSelected {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 26, height: 26)
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.purple)
                                    )
                                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                                    .position(x: 130, y: 20)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: 12) {
            if hasActiveFilters() {
                Text("\(totalSelectedFilters()) \(pluralizeFilters(totalSelectedFilters()))")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.top, 4)
            }
            
            HStack(spacing: 16) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        vm.resetFilters()
                    }
                }) {
                    Text("Сбросить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                .disabled(!hasActiveFilters())
                .opacity(hasActiveFilters() ? 1.0 : 0.5)
                
                Button(action: {
                    vm.apply()
                    dismiss()
                }) {
                    Text("Применить")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.purple, .blue]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .shadow(color: Color.purple.opacity(0.5), radius: 8, x: 0, y: 4)
                }
            }
            .padding()
        }
        .background(
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.2)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea()
        )
    }


    private func styleIconFor(_ style: NailStyle) -> some View {
        switch style {
        case .classic:
            return Image(systemName: "staroflife")
        case .bold:
            return Image(systemName: "sparkles")
        case .pastel:
            return Image(systemName: "cloud.fill")
        case .matte:
            return Image(systemName: "square.fill")
        case .nude:
            return Image(systemName: "drop.fill")
        case .dark:
            return Image(systemName: "moon.fill")
        }
    }
    
    private func styleGradientFor(_ style: NailStyle, isSelected: Bool) -> LinearGradient {
        let opacity: Double = isSelected ? 1.0 : 0.7
        switch style {
        case .classic:
            return LinearGradient(
                gradient: Gradient(colors: [Color.pink.opacity(opacity), Color.red.opacity(opacity)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .bold:
            return LinearGradient(
                gradient: Gradient(colors: [Color.red.opacity(opacity), Color.orange.opacity(opacity)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .pastel:
            return LinearGradient(
                gradient: Gradient(colors: [Color.mint.opacity(opacity), Color.green.opacity(opacity*0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .matte:
            return LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(opacity), Color.black.opacity(opacity*0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .nude:
            return LinearGradient(
                gradient: Gradient(colors: [Color(.systemPink).opacity(opacity*0.4), Color.pink.opacity(opacity*0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dark:
            return LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(opacity), Color.indigo.opacity(opacity)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private func seasonIconFor(_ season: Season) -> Image {
        switch season {
        case .spring:
            return Image(systemName: "leaf.fill")
        case .summer:
            return Image(systemName: "sun.max.fill")
        case .autumn:
            return Image(systemName: "leaf.arrow.triangle.circlepath")
        case .winter:
            return Image(systemName: "snowflake")
        case .party:
            return Image(systemName: "party.popper.fill")
        case .everyday:
            return Image(systemName: "calendar")
        }
    }
    
    private func seasonBackgroundFor(_ season: Season) -> LinearGradient {
        switch season {
        case .spring:
            return LinearGradient(
                gradient: Gradient(colors: [.green, .mint]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .summer:
            return LinearGradient(
                gradient: Gradient(colors: [.yellow, .orange]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .autumn:
            return LinearGradient(
                gradient: Gradient(colors: [.orange, .brown]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .winter:
            return LinearGradient(
                gradient: Gradient(colors: [.blue, .cyan]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .party:
            return LinearGradient(
                gradient: Gradient(colors: [.purple, .pink]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .everyday:
            return LinearGradient(
                gradient: Gradient(colors: [.gray, .gray.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private func seasonColorFor(_ season: Season) -> Color {
        switch season {
        case .spring: return .green
        case .summer: return .yellow
        case .autumn: return .orange
        case .winter: return .blue
        case .party: return .purple
        case .everyday: return .gray
        }
    }
    
    private func designTypeIconFor(_ type: DesignType) -> Image {
        switch type {
        case .french:
            return Image(systemName: "moon.circle.fill")
        case .ombre:
            return Image(systemName: "square.filled.on.square")
        case .matte:
            return Image(systemName: "circle.slash.fill")
        case .glitter:
            return Image(systemName: "sparkle")
        }
    }
    
    private func designTypeBackgroundFor(_ type: DesignType) -> LinearGradient {
        switch type {
        case .french:
            return LinearGradient(
                gradient: Gradient(colors: [.purple.opacity(0.7), .pink.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .ombre:
            return LinearGradient(
                gradient: Gradient(colors: [.blue.opacity(0.7), .purple.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .matte:
            return LinearGradient(
                gradient: Gradient(colors: [.gray.opacity(0.7), .black.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .glitter:
            return LinearGradient(
                gradient: Gradient(colors: [.pink.opacity(0.7), .orange.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private func totalSelectedFilters() -> Int {
        let colorCount = vm.filter.selectedColors.count
        let styleCount = vm.filter.selectedStyles.count
        let seasonCount = vm.filter.selectedSeasons.count
        let typeCount = vm.filter.selectedTypes.count
        
        return colorCount + styleCount + seasonCount + typeCount
    }
    
    
    private func hasActiveFilters() -> Bool {
        return !vm.filter.selectedColors.isEmpty ||
               !vm.filter.selectedStyles.isEmpty ||
               !vm.filter.selectedSeasons.isEmpty ||
               !vm.filter.selectedTypes.isEmpty
    }
    
    
    private func pluralizeFilters(_ count: Int) -> String {
        let mod10 = count % 10
        let mod100 = count % 100
        
        if mod10 == 1 && mod100 != 11 {
            return "фильтр активен"
        } else if (mod10 >= 2 && mod10 <= 4) && !(mod100 >= 12 && mod100 <= 14) {
            return "фильтра активны"
        } else {
            return "фильтров активно"
        }
    }
}
