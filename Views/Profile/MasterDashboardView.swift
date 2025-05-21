import SwiftUI

// Вынесем карточку дизайна в отдельное представление
struct MasterDesignCard: View {
    let design: NailDesign
    let colorProvider: (String) -> Color
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Верхняя часть - изображение
            DesignCardHeader(design: design, colorProvider: colorProvider)
            
            // Нижняя часть - информация
            DesignCardInfo(design: design)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        .padding(4)
        .onTapGesture {
            onTap()
        }
    }
}

// Верхняя часть карточки
struct DesignCardHeader: View {
    let design: NailDesign
    let colorProvider: (String) -> Color
    
    var body: some View {
        ZStack {
            // Фон изображения с градиентом
            Rectangle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [colorProvider(design.id), .white.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(height: 120)
            
            // Название дизайна
            Text(design.name)
                .font(.headline)
                .foregroundColor(.black)
                .padding(8)
                .background(Color.white.opacity(0.7))
                .cornerRadius(8)
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
        .mask(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .frame(height: 120)
                .padding(.bottom, -16)
        )
    }
}

// Нижняя часть карточки
struct DesignCardInfo: View {
    let design: NailDesign
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.1))
            
            VStack(spacing: 4) {
                Text(design.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 8)
                
                HStack {
                    ForEach(design.nailColors, id: \.self) { colorName in
                        if let color = NailColor(rawValue: colorName.rawValue) {
                            Circle()
                                .fill(color.color)
                                .frame(width: 12, height: 12)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity)
    }
}

// Заголовок профиля мастера
struct MasterProfileHeader: View {
    let user: UserProfile
    
    var body: some View {
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
}

// Пустое состояние
struct EmptyDesignsView: View {
    let onAddTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.7))
            
            Text("У вас пока нет загруженных дизайнов")
                .font(.headline)
                .foregroundColor(.white)
            
            Button(action: onAddTap) {
                Text("Добавить первый дизайн")
                    .font(.headline)
                    .foregroundColor(.purple)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding()
    }
}

// Основное представление панели мастера
struct MasterDashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var viewModel = MasterDesignsViewModel()
    @State private var showAddDesign = false
    @State private var selectedDesign: NailDesign?
    
    var body: some View {
        ZStack {
            // Фон
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Основное содержимое
            VStack(spacing: 20) {
                // Заголовок
                dashboardHeader
                
                // Информация о мастере
                if let user = authVM.user {
                    MasterProfileHeader(user: user)
                }
                
                // Содержимое в зависимости от состояния
                designsContent
            }
            .padding(.top, 16)
        }
        .sheet(isPresented: $showAddDesign) {
            if let username = authVM.user?.username {
                AddDesignView(viewModel: viewModel, username: username)
            }
        }
        .sheet(item: $selectedDesign) { design in
            if let username = authVM.user?.username {
                EditDesignView(viewModel: viewModel, design: design, username: username)
            }
        }
        .onAppear {
            loadMasterDesigns()
        }
        .alert(item: Binding<DesignAlert?>(
            get: { viewModel.errorMessage != nil ? DesignAlert(message: viewModel.errorMessage!) : nil },
            set: { _ in viewModel.errorMessage = nil }
        )) { alert in
            Alert(title: Text("Ошибка"), message: Text(alert.message), dismissButton: .default(Text("ОК")))
        }
    }
    
    // Заголовок панели
    private var dashboardHeader: some View {
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
    }
    
    // Содержимое в зависимости от состояния
    @ViewBuilder
    private var designsContent: some View {
        if viewModel.isLoading {
            Spacer()
            ProgressView()
                .scaleEffect(2)
                .tint(.white)
            Spacer()
        } else if viewModel.designs.isEmpty {
            EmptyDesignsView(onAddTap: { showAddDesign = true })
        } else {
            designsGridView
        }
    }
    
    // Сетка с дизайнами
    private var designsGridView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                ForEach(viewModel.designs) { design in
                    MasterDesignCard(
                        design: design,
                        colorProvider: viewModel.colorForDesign,
                        onTap: { selectedDesign = design }
                    )
                }
            }
            .padding()
        }
    }
    
    // Метод для загрузки дизайнов
    private func loadMasterDesigns() {
        if let username = authVM.user?.username {
            viewModel.loadDesigns(username: username)
        }
    }
}

struct DesignAlert: Identifiable {
    var id = UUID()
    var message: String
}
