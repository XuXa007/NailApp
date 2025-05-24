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
                    
                    if let errorMessage = authVM.errorMessage {
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                            .onTapGesture {
                                authVM.clearError()
                            }
                    }
                    
                    // Login form
                    VStack(spacing: 16) {
                        TextField("Имя пользователя", text: $username)
                            .textContentType(.username)
                            .autocapitalization(.none)
                            .textFieldStyle(FieldStyle())
                        
                        SecureField("Пароль", text: $password)
                            .textContentType(.password)
                            .textFieldStyle(FieldStyle())
                    }
                    .padding(.horizontal)
                    
                    // Login button
                    Button("Войти") {
                        Task {
                            await authVM.login(username: username, password: password)
                            if authVM.user != nil {
                                dismiss()
                            }
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal)
                    .disabled(authVM.isLoading || username.isEmpty || password.isEmpty)
                    .opacity((authVM.isLoading || username.isEmpty || password.isEmpty) ? 0.5 : 1.0)
                    
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
                    
                    // Demo login options (для разработки)
                    if Config.baseURL.contains("192.168") || Config.baseURL.contains("localhost") {
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
                                        Text("Демо Клиент")
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
                                        Text("Демо Мастер")
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
            }
            .navigationBarHidden(true)
            .overlay(
                Group {
                    if authVM.isLoading {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .overlay(
                                VStack {
                                    ProgressView()
                                        .scaleEffect(2)
                                        .tint(.white)
                                    
                                    Text("Вход в систему...")
                                        .foregroundColor(.white)
                                        .padding(.top)
                                }
                            )
                    }
                }
            )
        }
        .onAppear {
            username = ""
            password = ""
            authVM.clearError()
        }
    }
}
