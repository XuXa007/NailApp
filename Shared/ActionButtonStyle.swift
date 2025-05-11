import SwiftUI


struct ActionButtonStyle: ButtonStyle {
    var filled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(filled ? Color.purple : Color.clear)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white, lineWidth: filled ? 0 : 2)
            )
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
