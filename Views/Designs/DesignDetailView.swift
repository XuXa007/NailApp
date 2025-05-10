import SwiftUI

struct DesignDetailView: View {
    let design: NailDesign
    @EnvironmentObject var favVM: FavoritesViewModel

    var body: some View {
        VStack(spacing: 20) {
            if let url = design.imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: ProgressView().frame(height: 200)
                    case .success(let img): img.resizable().aspectRatio(contentMode: .fit)
                    case .failure: Color.gray.frame(height: 200)
                    @unknown default: EmptyView()
                    }
                }
            }

            Text(design.name).font(.title)

            Button(favVM.isFavorite(design) ? "Unfavorite" : "Favorite") {
                favVM.toggle(design)
            }

            NavigationLink("Try On") {
                ARTryOnView(design: design)
            }
            Spacer()
        }
        .padding()
    }
}
