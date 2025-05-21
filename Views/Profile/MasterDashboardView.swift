import SwiftUI

struct MasterDashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var designsVM = MasterDesignsViewModel()
    @State private var showAddDesign = false
    @State private var selectedDesign: NailDesign?
    
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
                    Text("Панель мастера")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                    Spacer()
                    
                    Button(action: {
                        showAddDesign = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                
                if let user = authVM.user {
                    // Информация о салоне
                    VStack(alignment: .leading, spacing: 8) {
                        Text(user.salonName ?? "Мой салон")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if let address = user.address {
                            Text(address)
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
                
                // Список дизайнов
                if designsVM.isLoading {
                    LoadingView()
                } else if designsVM.designs.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("У вас пока нет загруженных дизайнов")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            showAddDesign = true
                        }) {
                            Text("Добавить первый дизайн")
                                .font(.headline)
                                .foregroundColor(.purple)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                            ForEach(designsVM.designs) { design in
                                DesignCardView(design: design)
                                    .onTapGesture {
                                        selectedDesign = design
                                    }
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
            }
            .padding(.top, 16)
        }
        .sheet(isPresented: $showAddDesign) {
            AddDesignView(viewModel: designsVM, username: authVM.user?.username ?? "")
        }
        .sheet(item: $selectedDesign) { design in
            EditDesignView(viewModel: designsVM, design: design, username: authVM.user?.username ?? "")
        }
        .onAppear {
            if let username = authVM.user?.username {
                Task {
                    await designsVM.loadDesigns(username: username)
                }
            }
        }
        .alert(item: Binding<DesignAlert?>(
            get: { designsVM.errorMessage != nil ? DesignAlert(message: designsVM.errorMessage!) : nil },
            set: { _ in designsVM.errorMessage = nil }
        )) { alert in
            Alert(title: Text("Ошибка"), message: Text(alert.message), dismissButton: .default(Text("ОК")))
        }
    }
}

struct DesignAlert: Identifiable {
    let id = UUID()
    let message: String
}
