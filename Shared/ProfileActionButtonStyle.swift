import SwiftUI

struct ProfileActionButtonStyle: ButtonStyle {
    var filled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(
                Group {
                    if filled {
                        Color.purple
                    } else {
                        Color.clear
                    }
                }
            )
            .foregroundColor(filled ? .white : .purple)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.purple, lineWidth: filled ? 0 : 2)
            )
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
