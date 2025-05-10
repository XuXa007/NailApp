import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favVM: FavoritesViewModel

    var body: some View {
        List {
            ForEach(favVM.favorites) { design in
                DesignCardView(design: design)
            }
        }
        .navigationTitle("Favorites")
    }
}
