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
                DesignsView()
                    .environmentObject(designsVM)
                    .environmentObject(favVM)
            }
            .tabItem {
                Label("Каталог", systemImage: "square.grid.2x2.fill")
            }
            
            NavigationStack {
                ProfileView()
                    .environmentObject(authVM)
                    .environmentObject(favVM)
            }
            .tabItem {
                Label("Профиль", systemImage: "person.crop.circle.fill")
            }
        }
    }
}

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
