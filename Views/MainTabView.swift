import SwiftUI

struct MainTabView: View {
    @StateObject private var designsVM = DesignsViewModel()
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var favVM = FavoritesViewModel()
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        let gradientImage = UIImage.gradientImage(
            colors: [UIColor.purple.withAlphaComponent(0.3),
                     UIColor.blue.withAlphaComponent(0.3)],
            size: UIScreen.main.bounds.size
        )
        appearance.backgroundImage = gradientImage
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            NavigationStack {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                            ForEach(designsVM.filteredDesigns) { design in
                                NavigationLink {
                                    DesignDetailView(design: design)
                                        .environmentObject(favVM)
                                } label: {
                                    DesignCardView(design: design)
                                }
                            }
                        }
                        .padding(16)
                    }
                }
                .navigationTitle("Designs")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button { /* открыть фильтры */ } label: {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.white)
                        }
                    }
                }
                .task { await designsVM.loadDesigns() }
                .environmentObject(designsVM)
                .environmentObject(favVM)
            }
            .tabItem {
                Label("Designs", systemImage: "square.grid.2x2.fill")
            }
            
            NavigationStack {
                ProfileView()
                    .environmentObject(authVM)
                    .environmentObject(favVM)
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle.fill")
            }
        }
    }
}

//  для градиентного UIImage
private extension UIImage {
    static func gradientImage(colors: [UIColor], size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cgColors = colors.map { $0.cgColor } as CFArray
            let space = CGColorSpaceCreateDeviceRGB()
            let grad = CGGradient(colorsSpace: space, colors: cgColors, locations: [0,1])!
            ctx.cgContext.drawLinearGradient(
                grad,
                start: .zero,
                end: CGPoint(x: size.width, y: 0),
                options: []
            )
        }
    }
}
