import SwiftUI

struct LoginView: View {
    @Binding var isPresented: Bool
    var onLogin: () -> Void
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isRegistering: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Логотип или иконка
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                        .padding(.top, 40)
                    
                    // Заголовок
                    Text(isRegistering ? "Регистрация" : "Вход")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 20)
                    
                    // Поля ввода
                    VStack(spacing: 15) {
                        if isRegistering {
                            // Поле для имени пользователя (только при регистрации)
                            TextField("Имя пользователя", text: $username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                        
                        // Поле для email
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        // Поле для пароля
                        SecureField("Пароль", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                    
                    // Сообщение об ошибке
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.bottom, 5)
                    }
                    
                    // Кнопка входа/регистрации
                    Button(action: {
                        isLoading = true
                        if isRegistering {
                            register()
                        } else {
                            login()
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 5)
                            }
                            
                            Text(isRegistering ? "Зарегистрироваться" : "Войти")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(isLoading || !isFormValid())
                    
                    // Переключатель режима вход/регистрация
                    Button(action: {
                        isRegistering.toggle()
                        showError = false
                    }) {
                        Text(isRegistering ? "Уже есть аккаунт? Войти" : "Нет аккаунта? Зарегистрироваться")
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 10)
                    
                    // Кнопка входа для гостя
                    Button(action: {
                        loginAsGuest()
                    }) {
                        Text("Продолжить как гость")
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 5)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarItems(trailing: Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .padding()
            })
        }
    }
    
    // Проверка валидности формы
    private func isFormValid() -> Bool {
        if isRegistering {
            return !username.isEmpty && !email.isEmpty && password.count >= 6
        } else {
            return !email.isEmpty && password.count >= 6
        }
    }
    
    // Метод для входа
    private func login() {
        ApiService.shared.login(email: email, password: password) { user, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let user = user {
                    // Успешный вход
                    onLogin()
                    isPresented = false
                } else {
                    // Показываем ошибку
                    errorMessage = error?.localizedDescription ?? "Ошибка входа"
                    showError = true
                }
            }
        }
    }
    
    // Метод для регистрации
    private func register() {
        ApiService.shared.register(username: username, email: email, password: password) { user, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let user = user {
                    // Успешная регистрация
                    onLogin()
                    isPresented = false
                } else {
                    // Показываем ошибку
                    errorMessage = error?.localizedDescription ?? "Ошибка регистрации"
                    showError = true
                }
            }
        }
    }
    
    // Метод для входа как гость
    private func loginAsGuest() {
        ApiService.shared.loginAsGuest { user, error in
            DispatchQueue.main.async {
                if let user = user {
                    onLogin()
                    isPresented = false
                }
            }
        }
    }
}
