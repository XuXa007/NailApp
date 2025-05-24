import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isMaster = false
    @State private var salonName = ""
    @State private var address = ""
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
                
                ScrollView {
                    VStack(spacing: 32) {
                        Spacer().frame(height: 40)
                        
                        Image(systemName: "hand.raised.fill")
                            .resizable().scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.purple.opacity(0.4))
                                    .shadow(color: .purple.opacity(0.3), radius: 10)
                            )
                        
                        Text("Создание аккаунта")
                            .font(.largeTitle).bold()
                            .foregroundColor(.white)
                        
                        Text("Присоединяйтесь к сообществу ногтевого дизайна")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        
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
                        
                        Picker("Тип аккаунта", selection: $isMaster) {
                            Text("Клиент").tag(false)
                            Text("Мастер/Салон").tag(true)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            TextField("Имя пользователя", text: $username)
                                .textContentType(.nickname)
                                .autocapitalization(.none)
                                .textFieldStyle(FieldStyle())
                            
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .textFieldStyle(FieldStyle())
                            
                            SecureField("Пароль", text: $password)
                                .textContentType(.newPassword)
                                .textFieldStyle(FieldStyle())
                            
                            SecureField("Подтвердите пароль", text: $confirmPassword)
                                .textContentType(.newPassword)
                                .textFieldStyle(FieldStyle())
                            
                            if isMaster {
                                TextField("Название салона", text: $salonName)
                                    .textContentType(.organizationName)
                                    .textFieldStyle(FieldStyle())
                                
                                TextField("Адрес", text: $address)
                                    .textContentType(.fullStreetAddress)
                                    .textFieldStyle(FieldStyle())
                            }
                        }
                        .padding(.horizontal)
                        
                        // Validation messages
                        VStack(alignment: .leading, spacing: 4) {
                            if !password.isEmpty && password.count < 6 {
                                Text("Пароль должен содержать минимум 6 символов")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            
                            if !confirmPassword.isEmpty && password != confirmPassword {
                                Text("Пароли не совпадают")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            
                            if !email.isEmpty && !isValidEmail(email) {
                                Text("Некорректный email адрес")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                        Button("Зарегистрироваться") {
                            Task {
                                if isMaster {
                                    await authVM.registerMaster(
                                        username: username,
                                        email: email,
                                        password: password,
                                        salonName: salonName,
                                        address: address
                                    )
                                } else {
                                    await authVM.registerClient(
                                        username: username,
                                        email: email,
                                        password: password
                                    )
                                }
                                
                                if authVM.user != nil {
                                    dismiss()
                                }
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal)
                        .disabled(!isFormValid || authVM.isLoading)
                        .opacity((isFormValid && !authVM.isLoading) ? 1.0 : 0.5)
                        
                        HStack {
                            Text("Уже есть аккаунт?")
                                .foregroundColor(.white.opacity(0.8))
                            Button("Войти") {
                                dismiss()
                            }
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                        }
                        
                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal)
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
                                    
                                    Text("Создание аккаунта...")
                                        .foregroundColor(.white)
                                        .padding(.top)
                                }
                            )
                    }
                }
            )
        }
        .onAppear {
            authVM.clearError()
        }
    }
    
    private var isFormValid: Bool {
        let basicValid = !username.isEmpty &&
                        !email.isEmpty &&
                        isValidEmail(email) &&
                        password.count >= 6 &&
                        password == confirmPassword
        
        if isMaster {
            return basicValid && !salonName.isEmpty && !address.isEmpty
        } else {
            return basicValid
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}
