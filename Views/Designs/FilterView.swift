import SwiftUI

struct FilterView: View {
    @ObservedObject var vm: FilterViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // полоса
                Capsule()
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        filterSection(
                            title: "Цвета",
                            items: vm.availableColors,
                            isSelected: { vm.filter.selectedColors.contains($0) },
                            colorFor: { $0.color },      // ← здесь
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
                            colorFor: { _ in .accentColor },
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
                            colorFor: { _ in .accentColor },
                            toggle: { season in
                                if vm.filter.selectedSeasons.contains(season) {
                                    vm.filter.selectedSeasons.remove(season)
                                } else {
                                    vm.filter.selectedSeasons.insert(season)
                                }
                            }
                        )
                        
                        filterSection(
                            title: "Тип",
                            items: vm.availableTypes,
                            isSelected: { vm.filter.selectedTypes.contains($0) },
                            colorFor: { _ in .accentColor },
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
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Применить") {
                        vm.apply()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отменить") { dismiss() }
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
                .padding(.leading, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items) { item in
                        let selected = isSelected(item)
                        Text(item.description.capitalized)
                            .font(.subheadline)
                            .foregroundColor(selected ? .white : .primary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background {
                                if selected {
                                    colorFor(item)
                                        .cornerRadius(20)
                                        .shadow(color: colorFor(item).opacity(0.4),
                                                radius: 4, x: 0, y: 2)
                                } else {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
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
}
