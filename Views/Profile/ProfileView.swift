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
                    VStack(spacing: 16) {
                        Image(systemName: user.role == .master ? "scissors" : "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                            )
                        
                        VStack(spacing: 4) {
                            Text(user.username)
                                .font(.title2).bold()
                                .foregroundColor(.white)
                            
                            Text(user.role == .master ? "Мастер" : "Клиент")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        if user.role == .master, let salonName = user.salonName {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Салон: \(salonName)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                if let address = user.address {
                                    Text("Адрес: \(address)")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
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
                    VStack(spacing: 24) {
                        Image(systemName: "person.crop.circle.badge.exclamationmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.bottom, 20)
                        
                        Text("Войдите, чтобы получить доступ к своему профилю")
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Войти") {
                            showLogin = true
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                        
                        Button("Регистрация") {
                            showRegister = true
                        }
                        .buttonStyle(ProfileActionButtonStyle(filled: false))
                        .padding(.horizontal, 40)
                    }
                    .frame(maxHeight: .infinity)
                }
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
