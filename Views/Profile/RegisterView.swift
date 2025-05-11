import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer().frame(height: 40)
                
                Image(systemName: "hand.raised.fill")
                    .resizable().scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.purple)
                
                Text("Create Account")
                    .font(.largeTitle).bold()
                Text("Join us and try nail designs")
                    .font(.subheadline).foregroundColor(.secondary)
                
                VStack(spacing: 16) {
                    TextField("Username", text: $username)
                        .textContentType(.nickname)
                        .textFieldStyle(FieldStyle())
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textFieldStyle(FieldStyle())
                    
                    SecureField("Password", text: $password)
                        .textContentType(.newPassword)
                        .textFieldStyle(FieldStyle())
                }
                .padding(.horizontal)
                
                Button("Зарегистрироваться") {
                    Task {
                        await authVM.register(username: username, email: email, password: password)
                        if authVM.user != nil { dismiss() }
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal)
                
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
        }
    }
}
