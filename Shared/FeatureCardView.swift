import SwiftUI

struct FeatureCardView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .frame(height: 150)
            .overlay(Text("Feature"))
    }
}
