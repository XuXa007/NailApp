import SwiftUI

struct DesignsView: View {
    @EnvironmentObject private var vm: DesignsViewModel
    @EnvironmentObject private var favVM: FavoritesViewModel
    @State private var showFilter = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Text("Каталог")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                        showFilter.toggle()
                    } label: {
                        Label("Фильтр", systemImage: "line.horizontal.3.decrease.circle")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Сетка
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                        ForEach(vm.filteredDesigns) { design in
                            NavigationLink {
                                DesignDetailView(design: design)
                                    .environmentObject(favVM)
                            } label: {
                                DesignCardView(design: design)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showFilter) {
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
