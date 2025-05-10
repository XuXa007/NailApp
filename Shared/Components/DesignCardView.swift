import SwiftUI

struct DesignCardView: View {
    let design: NailDesign

    var body: some View {
        VStack {
            if let url = design.imageURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: ProgressView()
                    case .success(let img): img.resizable().scaledToFill()
                    case .failure: Color.gray
                    @unknown default: EmptyView()
                    }
                }
                .frame(height: 120)
                .clipped()
            }

            Text(design.name)
                .font(.headline)
                .padding(8)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}
