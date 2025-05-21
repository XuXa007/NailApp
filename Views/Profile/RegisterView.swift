import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
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
                    
                    // Переключатель типа аккаунта
                    Picker("Тип аккаунта", selection: $isMaster) {
                        Text("Клиент").tag(false)
                        Text("Мастер/Салон").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    VStack(spacing: 16) {
                        TextField("Имя пользователя", text: $username)
                            .textContentType(.nickname)
                            .textFieldStyle(FieldStyle())
                        
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .textFieldStyle(FieldStyle())
                        
                        SecureField("Пароль", text: $password)
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
                    
                    Button("Зарегистрироваться") {
                        // Важное изменение: используем синхронные методы вместо async
                        if isMaster {
                            authVM.registerMasterSync(
                                username: username,
                                email: email,
                                password: password,
                                salonName: salonName,
                                address: address
                            )
                        } else {
                            authVM.registerClientSync(
                                username: username,
                                email: email,
                                password: password
                            )
                        }
                        
                        // Отложенное закрытие экрана для имитации задержки
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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
                    
                    Spacer()
                }
                .padding(.horizontal)
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
    
    private var isFormValid: Bool {
        let basicValid = !username.isEmpty && !email.isEmpty && password.count >= 6
        
        if isMaster {
            return basicValid && !salonName.isEmpty && !address.isEmpty
        } else {
            return basicValid
        }
    }
}
