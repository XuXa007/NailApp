import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack { ProgressView().scaleEffect(2) }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
