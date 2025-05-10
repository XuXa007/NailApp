import SwiftUI

extension View {
    func cardStyle() -> some View {
        self.padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
    }
}
