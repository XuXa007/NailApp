import SwiftUI

// Текстовые поля
struct FieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: — Основная кнопка
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .shadow(color: Color.purple.opacity(0.4), radius: 8, x: 0, y: 4)
    }
}
