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
                    
                    Button(action: {
                        self.showFilter = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 44)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.6)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
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
            print("Sheet closed")
        } content: {
            FilterView(
                vm: FilterViewModel(
                    filter: vm.designFilter,
                    apply: { newFilter in
                        vm.designFilter = newFilter
                        vm.applyLocalFiltering()
                    }
                )
            )
        }
        .task { await vm.loadDesigns() }
    }
}
