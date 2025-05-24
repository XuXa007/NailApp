import SwiftUI

struct MasterDesignDetailView: View {
    let design: NailDesign
    @ObservedObject var viewModel: MasterDesignsViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.4), Color.blue.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Изображение
                    if let url = design.imageURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: 300)
                            case .success(let img):
                                img
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                Color.gray.opacity(0.3)
                                    .overlay(
                                        Text("Изображение недоступно")
                                            .foregroundColor(.white)
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(height: 300)
                        .clipped()
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                    }
                    
                    Text(design.name)
                        .font(.title2).fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    detailsCard
                    
                    // Кнопки действий
                    HStack(spacing: 16) {
                        Button {
                            showDeleteAlert = true
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                        .buttonStyle(ActionButtonStyle(filled: false))
                        .foregroundColor(.red)
                        
                        Button {
                            showEditSheet = true
                        } label: {
                            Label("Редактировать", systemImage: "pencil")
                        }
                        .buttonStyle(ActionButtonStyle())
                        
                        NavigationLink {
                            ARTryOnView(design: design)
                        } label: {
                            Label("Примерить", systemImage: "sparkles")
                        }
                        .buttonStyle(ActionButtonStyle())
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 32)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            if let username = authVM.user?.username {
                EditDesignView(viewModel: viewModel, design: design, username: username)
            }
        }
        .alert("Удалить дизайн", isPresented: $showDeleteAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Удалить", role: .destructive) {
                Task {
                    if let username = authVM.user?.username {
                        let success = await viewModel.deleteDesign(id: design.id)
                        if success {
                            dismiss()
                        }
                    }
                }
            }
        } message: {
            Text("Вы уверены, что хотите удалить этот дизайн? Это действие нельзя отменить.")
        }
    }
    
    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Детали")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(design.nailColors, id: \.self) { c in
                        ColorChip(color: c)
                    }
                }
                .padding(.vertical, 4)
            }
            
            VStack(spacing: 8) {
                InfoRow(label: "Стиль", value: localizedValue(design.designType))
                InfoRow(label: "Сезон", value: localizedValue(design.occasion))
                InfoRow(label: "Длина", value: localizedValue(design.length))
                InfoRow(label: "Материал", value: localizedValue(design.material))
                
                if let createdBy = design.createdBy {
                    InfoRow(label: "Автор", value: createdBy)
                }
                
                if let salonName = design.salonName {
                    InfoRow(label: "Салон", value: salonName)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
    
    private func localizedValue(_ value: String) -> String {
        let lowercased = value.lowercased()
        
        if let type = DesignType(rawValue: lowercased) {
            return type.description
        }
        
        if let style = NailStyle(rawValue: lowercased) {
            return style.description
        }
        
        if let season = Season(rawValue: lowercased) {
            return season.description
        }
        
        if let length = NailLength(rawValue: lowercased) {
            return length.description
        }
        
        if let material = DesignMaterial(rawValue: lowercased) {
            return material.description
        }
        
        return value.capitalized
    }
}
