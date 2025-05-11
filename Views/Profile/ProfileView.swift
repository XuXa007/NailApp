import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var favVM: FavoritesViewModel
    @State private var showLogin = false
    @State private var showRegister = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Text("Профиль")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                if let user = authVM.user {
                    // Инфо
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white.opacity(0.8))
                        Text(user.username)
                            .font(.title2).bold()
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 8)
                    
                    FavoritesSectionView()
                        .environmentObject(favVM)
                    
                    Spacer()
                    
                    Button {
                        authVM.logout()
                    } label: {
                        Label("Выйти", systemImage: "arrow.backward.circle.fill")
                            .font(.headline)
                            .foregroundColor(.purple)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .padding(.bottom, 32)
                } else {
                    VStack(spacing: 16) {
                        Button("Войти") {
                            showLogin = true
                        }
                        .buttonStyle(ProfileActionButtonStyle())
                        
                        Button("Регистрация") {
                            showRegister = true
                        }
                        .buttonStyle(ProfileActionButtonStyle(filled: false))
                    }
                }
                
                Spacer()
            }
        }
        .sheet(isPresented: $showLogin) {
            LoginView().environmentObject(authVM)
        }
        .sheet(isPresented: $showRegister) {
            RegisterView().environmentObject(authVM)
        }
    }
}
