import SwiftUI

struct FilterView: View {
    @ObservedObject var vm: FilterViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Capsule()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 40, height: 5)
                        .padding(.top, 8)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            filterSection(
                                title: "Цвет",
                                items: vm.availableColors,
                                isSelected: { vm.filter.selectedColors.contains($0) },
                                colorFor: { $0.color },
                                toggle: { color in
                                    if vm.filter.selectedColors.contains(color) {
                                        vm.filter.selectedColors.remove(color)
                                    } else {
                                        vm.filter.selectedColors.insert(color)
                                    }
                                }
                            )
                            
                            filterSection(
                                title: "Стиль",
                                items: vm.availableStyles,
                                isSelected: { vm.filter.selectedStyles.contains($0) },
                                colorFor: { _ in Color.pink.opacity(0.8) },
                                toggle: { style in
                                    if vm.filter.selectedStyles.contains(style) {
                                        vm.filter.selectedStyles.remove(style)
                                    } else {
                                        vm.filter.selectedStyles.insert(style)
                                    }
                                }
                            )
                            
                            filterSection(
                                title: "Сезон",
                                items: vm.availableSeasons,
                                isSelected: { vm.filter.selectedSeasons.contains($0) },
                                colorFor: { season in
                                    switch season {
                                    case .spring: return .green.opacity(0.8)
                                    case .summer: return .yellow.opacity(0.8)
                                    case .autumn: return .orange.opacity(0.8)
                                    case .winter: return .blue.opacity(0.8)
                                    }
                                },
                                toggle: { season in
                                    if vm.filter.selectedSeasons.contains(season) {
                                        vm.filter.selectedSeasons.remove(season)
                                    } else {
                                        vm.filter.selectedSeasons.insert(season)
                                    }
                                }
                            )
                            
                            filterSection(
                                title: "Длина",
                                items: vm.availableTypes,
                                isSelected: { vm.filter.selectedTypes.contains($0) },
                                colorFor: { _ in .purple.opacity(0.8) },
                                toggle: { type in
                                    if vm.filter.selectedTypes.contains(type) {
                                        vm.filter.selectedTypes.remove(type)
                                    } else {
                                        vm.filter.selectedTypes.insert(type)
                                    }
                                }
                            )
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack(spacing: 12) {
                        Button("Применить") {
                            vm.apply()
                            dismiss()
                        }
                        .buttonStyle(ActionButtonStyle())
                        
                        Button("Сбросить") {
                            vm.filter = DesignFilter()
                        }
                        .buttonStyle(ActionButtonStyle(filled: false))
                    }
                    .padding()
                }
            }
            .navigationTitle("Фильтры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    @ViewBuilder
    private func filterSection<Item: Identifiable & CustomStringConvertible>(
        title: String,
        items: [Item],
        isSelected: @escaping (Item) -> Bool,
        colorFor: @escaping (Item) -> Color,
        toggle: @escaping (Item) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items) { item in
                        let selected = isSelected(item)
                        // Русские названия для элементов фильтра
                        Text(localizedName(for: item))
                            .font(.subheadline)
                            .foregroundColor(selected ? .white : .primary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background {
                                if selected {
                                    LinearGradient(
                                        gradient: Gradient(colors: [colorFor(item), colorFor(item).opacity(0.7)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .cornerRadius(20)
                                    .shadow(color: colorFor(item).opacity(0.4), radius: 4, x: 0, y: 2)
                                } else {
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.white.opacity(0.15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                    toggle(item)
                                }
                            }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    private func localizedName<T>(for item: T) -> String {
        if let color = item as? NailColor {
            switch color {
            case .pink: return "Розовый"
            case .purple: return "Фиолетовый"
            case .red: return "Красный"
            case .blue: return "Синий"
            case .green: return "Зелёный"
            case .gray: return "Серый"
            
            }
        } else if let style = item as? NailStyle {
            switch style {
            case .floral: return "Цветочный"
            case .geometric: return "Геометрический"
            case .minimal: return "Минимализм"
            case .abstract: return "Абстрактный"
            }
        } else if let season = item as? Season {
            switch season {
            case .spring: return "Весна"
            case .summer: return "Лето"
            case .autumn: return "Осень"
            case .winter: return "Зима"
            }
        } else if let type = item as? DesignType {
            switch type {
            case .french: return "Френч"
            case .ombre: return "Омбре"
            case .matte: return "Матовый"
            case .glitter: return "Блестки"
            }
        }
        return (item as? CustomStringConvertible)?.description.capitalized ?? "Неизвестно"
    }
}
