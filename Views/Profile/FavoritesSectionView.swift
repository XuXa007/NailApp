import SwiftUI

struct FavoritesSectionView: View {
    @EnvironmentObject private var favVM: FavoritesViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Избранное")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            if authVM.user == nil {
                Text("Войдите, чтобы увидеть избранное")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal)
            } else if favVM.isLoading {
                ProgressView().padding()
            } else if favVM.items.isEmpty {
                Text("Нет сохранённых дизайнов")
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(favVM.items.prefix(5)) { design in
                            NavigationLink {
                                DesignDetailView(design: design)
                                    .environmentObject(favVM)
                            } label: {
                                favoriteDesignCard(design)
                            }
                        }
                        
                        if favVM.items.count > 5 {
                            NavigationLink {
                                FavoritesView()
                                    .environmentObject(favVM)
                            } label: {
                                showMoreCard(count: favVM.items.count - 5)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .task {
            if authVM.user != nil {
                await favVM.loadFavorites()
            }
        }
    }
    
    private func favoriteDesignCard(_ design: NailDesign) -> some View {
        VStack {
            if let url = design.imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: Color.gray.opacity(0.3)
                    case .success(let image): image.resizable().scaledToFill()
                    case .failure: Color.red.opacity(0.3)
                    @unknown default: EmptyView()
                    }
                }
                .frame(width: 100, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            Text(design.name)
                .font(.caption)
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(width: 100)
        }
    }
    
    private func showMoreCard(count: Int) -> some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 100, height: 120)
                
                VStack {
                    Text("+\(count)")
                        .font(.title2).bold()
                        .foregroundColor(.white)
                    
                    Text("Ещё")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            
            Text("Показать все")
                .font(.caption)
                .foregroundColor(.white)
                .frame(width: 100)
        }
    }
}
