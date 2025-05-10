import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email    = ""
    @State private var password = ""
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer().frame(height: 40)

                // Логотип
                Image(systemName: "hand.raised.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.purple)

                Text("Nail Design")
                    .font(.largeTitle).bold()
                Text("Find your perfect nail style")
                    .font(.subheadline).foregroundColor(.secondary)

                // Поля ввода
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.username)
                        .textFieldStyle(FieldStyle())

                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .textFieldStyle(FieldStyle())
                }
                .padding(.horizontal)

                // Кнопка входа
                Button("Войти") {
                    Task {
                        await authVM.login(username: email, password: password)
                        if authVM.user != nil { dismiss() }
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal)

                // Ссылка на регистрацию
                HStack {
                    Text("Нет аккаунта?")
                        .foregroundColor(.secondary)
                    Button("Зарегистрироваться") {
                        // Переключиться на RegisterView
                        // Для простоты, вызовем через dismiss и NavigationLink
                    }
                    .foregroundColor(.purple)
                }

                Spacer()

                // Демо режим
                Button("Демо режим (без регистрации)") {
                    authVM.user = UserProfile(id: UUID(), username: "Demo", email: "")
                    dismiss()
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
            }
            .navigationBarHidden(true)
        }
    }
}
