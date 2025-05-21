import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var username = ""
    @State private var password = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer().frame(height: 40)
                    
                    // Logo and app name
                    Image(systemName: "hand.raised.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            Circle()
                                .fill(Color.purple.opacity(0.4))
                                .shadow(color: .purple.opacity(0.3), radius: 10)
                        )
                    
                    Text("Nail Design")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                    
                    Text("Найдите свой идеальный дизайн ногтей")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.bottom, 20)
                    
                    // Login form
                    VStack(spacing: 16) {
                        TextField("Имя пользователя", text: $username)
                            .textContentType(.username)
                            .textFieldStyle(FieldStyle())
                        
                        SecureField("Пароль", text: $password)
                            .textContentType(.password)
                            .textFieldStyle(FieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // Login button
                    Button("Войти") {
                        authVM.login(username: username, password: password)
                        
                        // Отложенное закрытие экрана
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            if authVM.user != nil {
                                dismiss()
                            }
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                    .disabled(authVM.isLoading)
                    .opacity(authVM.isLoading ? 0.5 : 1.0)
                    
                    // Register link
                    HStack {
                        Text("Нет аккаунта?")
                            .foregroundColor(.white.opacity(0.8))
                        
                        NavigationLink("Зарегистрироваться", destination: RegisterView())
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 8)
                    
                    Spacer()
                    
                    // Demo login options
                    VStack(spacing: 16) {
                        Text("Быстрый вход для демонстрации")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack(spacing: 16) {
                            Button {
                                authVM.loginAsClient()
                                dismiss()
                            } label: {
                                VStack {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 24))
                                        .padding(.bottom, 4)
                                    Text("Клиент")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                            }
                            
                            Button {
                                authVM.loginAsMaster()
                                dismiss()
                            } label: {
                                VStack {
                                    Image(systemName: "scissors")
                                        .font(.system(size: 24))
                                        .padding(.bottom, 4)
                                    Text("Мастер")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
            .overlay(
                Group {
                    if authVM.isLoading {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .overlay(
                                ProgressView()
                                    .scaleEffect(2)
                                    .tint(.white)
                            )
                    }
                }
            )
        }
    }
}
