import SwiftUI

struct FavoritesSectionView: View {
    @EnvironmentObject private var favVM: FavoritesViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
//            Text("Избранное")
//                .font(.headline)
//                .foregroundColor(.white)
//                .padding(.horizontal)
            
//            if favVM.isLoading {
//                ProgressView().padding()
//            } else if favVM.items.isEmpty {
//                Text("Нет сохранённых дизайнов")
//                    .foregroundColor(.white.opacity(0.7))
//                    .padding()
//            } else {
//                ScrollView {
//                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 16)], spacing: 16) {
//                        ForEach(favVM.items) { design in
//                            NavigationLink {
//                                DesignDetailView(design: design)
//                                    .environmentObject(favVM)
//                            } label: {
//                                DesignCardView(design: design)
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//            }
        }
        .task { await favVM.loadFavorites() }
    }
}
