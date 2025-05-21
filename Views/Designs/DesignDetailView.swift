import SwiftUI

struct DesignDetailView: View {
    let design: NailDesign
    @EnvironmentObject var favVM: FavoritesViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showLoginSheet = false
    
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
                            case .empty:    ProgressView().frame(height: 300)
                            case .success(let img): img.resizable().scaledToFill()
                            case .failure:  Color.gray
                            @unknown default: EmptyView()
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
                    
                    HStack(spacing: 16) {
                        Button {
                            if authVM.user != nil {
                                favVM.toggle(design)
                            } else {
                                showLoginSheet = true
                            }
                        } label: {
                            Label(
                                favVM.isFavorite(design) ? "Удалить" : "В избранное",
                                systemImage: favVM.isFavorite(design) ? "heart.fill" : "heart"
                            )
                        }
                        .buttonStyle(ActionButtonStyle(filled: false))
                        
                        NavigationLink {
                            ARTryOnView(design: design)
                        } label: {
                            Label("Примерить", systemImage: "sparkles")
                                .buttonStyle(ActionButtonStyle())
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
        .sheet(isPresented: $showLoginSheet) {
            LoginView().environmentObject(authVM)
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

    // Обновленный метод для локализации значений
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
        
        switch lowercased {
        case "french": return "Френч"
        case "ombre": return "Омбре"
        case "matte": return "Матовый"
        case "glitter": return "Блестки"
        
        case "spring": return "Весна"
        case "summer": return "Лето"
        case "autumn", "fall": return "Осень"
        case "winter": return "Зима"
        case "everyday": return "Повседневный"
        case "party": return "Праздничный"
            
        case "short": return "Короткие"
        case "medium": return "Средние"
        case "long": return "Длинные"
            
        case "gel": return "Гель"
        case "acrylic": return "Акрил"
        case "regular": return "Обычный"
        case "polygel": return "Полигель"
            
        default: return value.capitalized
        }
    }
}
