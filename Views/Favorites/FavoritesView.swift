import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favVM: FavoritesViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    Text("Избранное")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                        .padding(.top, 16)
                    
                    if favVM.isLoading {
                        ProgressView()
                            .padding()
                    } else if favVM.items.isEmpty {
                        Text("У вас нет сохранённых дизайнов")
                            .foregroundColor(.white.opacity(0.7))
                            .padding()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                                ForEach(favVM.items) { design in
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
                    
                    Spacer()
                }
            }
            .task { await favVM.loadFavorites() }
        }
    }
}
