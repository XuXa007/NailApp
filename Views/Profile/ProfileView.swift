import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showLogin = false
    var body: some View {
        Group {
            if let user = authVM.user {
                VStack(spacing: 20) {
                    Text("Hello, \(user.username)!")
                        .font(.title)
                    Button("Logout") { authVM.logout() }
                }
            } else {
                VStack(spacing: 20) {
                    Button("Login") { showLogin = true }
                    Button("Register") { showLogin = true }
                }
                .sheet(isPresented: $showLogin) {
                    LoginView()
                }
            }
        }
        .navigationTitle("Profile")
    }
}
