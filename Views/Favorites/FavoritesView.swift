import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favVM: FavoritesViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @State private var hasAppeared = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
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
                    
                    if authVM.user == nil {
                        // User not logged in
                        notLoggedInView
                    } else if favVM.isLoading {
                        // Loading state
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                            .padding()
                    } else if favVM.items.isEmpty {
                        // Empty state
                        VStack(spacing: 16) {
                            Image(systemName: "heart")
                                .font(.system(size: 60))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text("У вас нет сохранённых дизайнов")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Text("Добавляйте понравившиеся дизайны в избранное, нажимая на ❤️")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                    } else {
                        // Favorites list
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                                ForEach(favVM.items) { design in
                                    NavigationLink {
                                        DesignDetailView(design: design)
                                            .environmentObject(favVM)
                                            .environmentObject(authVM)
                                    } label: {
                                        DesignCardView(design: design)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .onAppear {
                if !hasAppeared {
                    hasAppeared = true
                    // Связываем ViewModels при первом появлении экрана
                    favVM.setAuthViewModel(authVM)
                    authVM.setFavoritesViewModel(favVM)
                    
                    // Загружаем избранное только если пользователь залогинен
                    if authVM.user != nil {
                        Task {
                            await favVM.loadFavorites()
                        }
                    }
                }
            }
            .onChange(of: authVM.user?.id) { _ in
                Task {
                    if authVM.user != nil {
                        await favVM.loadFavorites()
                    } else {
                        favVM.clearFavorites()
                    }
                }
            }
        }
    }
    
    // View for when user is not logged in
    private var notLoggedInView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 10)
            
            Text("Войдите в аккаунт, чтобы сохранять дизайны в избранное")
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            NavigationLink(destination: LoginView().environmentObject(authVM)) {
                Text("Войти")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .blue]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.purple.opacity(0.5), radius: 5)
            }
            
            Spacer()
        }
        .padding()
    }
}
