import SwiftUI

struct ColorChip: View {
    let color: NailColor

    var body: some View {
        Text(color.rawValue.capitalized)
            .font(.caption).bold()
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background(color.color.opacity(0.8))
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}
