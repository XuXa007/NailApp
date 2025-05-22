import SwiftUI

struct MasterDashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var viewModel = MasterDesignsViewModel()
    @State private var showAddDesign = false
    @State private var hasLoaded = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Заголовок
                HStack {
                    Text("Мои дизайны")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        showAddDesign = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Информация о мастере
                if let user = authVM.user, user.role == .master {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(user.salonName ?? "Мой салон")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if let address = user.address {
                            Text(address)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Text("Дизайнов: \(viewModel.designs.count)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 16)
                }
                
                // Контент
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(2)
                        .tint(.white)
                    Spacer()
                } else if viewModel.designs.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("У вас пока нет дизайнов")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Button("Добавить первый дизайн") {
                            showAddDesign = true
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, 40)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                            ForEach(viewModel.designs) { design in
                                NavigationLink {
                                    MasterDesignDetailView(design: design, viewModel: viewModel)
                                        .environmentObject(authVM)
                                } label: {
                                    DesignCardView(design: design)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .sheet(isPresented: $showAddDesign) {
            if let username = authVM.user?.username {
                AddDesignView(viewModel: viewModel, username: username)
            }
        }
        .task {
            if !hasLoaded, let username = authVM.user?.username {
                hasLoaded = true
                await viewModel.loadDesigns(username: username)
            }
        }
        .refreshable {
            if let username = authVM.user?.username {
                await viewModel.loadDesigns(username: username)
            }
        }
        .alert("Ошибка", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
