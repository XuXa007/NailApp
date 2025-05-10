import SwiftUI

struct DesignsView: View {
    @EnvironmentObject private var vm: DesignsViewModel
    @State private var showFilter = false

    var body: some View {
        Group {
            if vm.isLoading {
                LoadingView()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                        ForEach(vm.filteredDesigns) { design in
                            DesignCardView(design: design)
                                .onTapGesture {
                                    // тут можно делать навигацию в DesignDetailView(design:)
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Designs")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showFilter.toggle()
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
            }
        }
        .sheet(isPresented: $showFilter) {
            // Исправлено: использую правильный способ инициализации FilterViewModel
            FilterView(
                vm: FilterViewModel(
                    filter: vm.designFilter,
                    apply: { newFilter in
                        vm.designFilter = newFilter
                        Task { await vm.loadDesigns() }
                    }
                )
            )
        }
        .task { await vm.loadDesigns() }
    }
}
