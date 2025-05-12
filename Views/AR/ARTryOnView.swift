import SwiftUI
import Combine

// Представление, в котором пользователь выбирает фото,
// отправляет его на сервер и видит результат (маску)
struct ARTryOnView: View {
    @StateObject private var vm = ARViewModel()
    @State private var inputImage: UIImage?
    @State private var showPicker = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Отображаем результат или подсказку
                if vm.isLoading {
                    ProgressView("Генерируем маску…")
                }
                else if let mask = vm.maskImage {
                    Image(uiImage: mask)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }
                else {
                    Text("Загрузите фото, чтобы создать маску")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                // Кнопки действия
                HStack(spacing: 16) {
                    Button(action: { showPicker = true }) {
                        Label("Выбрать фото", systemImage: "photo")
                    }
                    .buttonStyle(.borderedProminent)

                    if inputImage != nil {
                        Button(action: {
                            vm.generateMask(from: inputImage!)
                        }) {
                            Label("Сгенерировать маску", systemImage: "wand.and.stars")
                        }
                        .buttonStyle(.bordered)
                    }
                }

                // Ошибка
                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("AR Try-On")
            .sheet(isPresented: $showPicker) {
                ImagePickerView(image: $inputImage)
            }
            // Как только пользователь выбрал изображение — сразу генерируем маску
            .onChange(of: inputImage) { oldValue, newValue in
                if let img = newValue {
                    vm.generateMask(from: img)
                }
            }
        }
    }
}

struct ARTryOnView_Previews: PreviewProvider {
    static var previews: some View {
        ARTryOnView()
    }
}
