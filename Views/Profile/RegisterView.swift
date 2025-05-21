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
            VStack(spacing: 32) {
                Spacer().frame(height: 40)
                
                Image(systemName: "hand.raised.fill")
                    .resizable().scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.purple)
                
                Text("Создание аккаунта")
                    .font(.largeTitle).bold()
                Text("Присоединяйтесь к сообществу ногтевого дизайна")
                    .font(.subheadline).foregroundColor(.secondary)
                
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
                        
                        if authVM.user != nil { dismiss() }
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal)
                .disabled(!isFormValid)
                .opacity(isFormValid ? 1.0 : 0.5)
                
                HStack {
                    Text("Уже есть аккаунт?")
                        .foregroundColor(.secondary)
                    Button("Войти") {
                        dismiss()
                    }
                    .foregroundColor(.purple)
                }
                
                Spacer()
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
