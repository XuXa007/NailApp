import SwiftUI

struct ARTryOnView: View {
    let design: NailDesign
    @StateObject private var vm = ARViewModel()
    @State private var showPicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            if let out = vm.outputImage {
                Image(uiImage: out)
                    .resizable()
                    .scaledToFit()
            } else {
                Button("Pick Photo") {
                    showPicker = true
                }
            }
            Spacer()
        }
        .navigationTitle("Try On")
        .sheet(isPresented: $showPicker) {
            ImagePickerView(image: $vm.selectedImage)
                .onChange(of: vm.selectedImage) { oldValue, newValue in
                    Task {
                        // загрузить
                        guard let url = design.imageURL,
                              let (data, _) = try? await URLSession.shared.data(from: url),
                              let uiDesign = UIImage(data: data) else {
                            return
                        }
                        // наложить ??
                        vm.apply(design: uiDesign)
                    }
                }
        }
    }
}
