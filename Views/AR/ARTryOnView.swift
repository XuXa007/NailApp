import SwiftUI
import Combine

struct ARTryOnView: View {
    // Дизайн передается при создании компонента
    let design: NailDesign
    
    @StateObject private var vm = ARViewModel()
    @State private var inputImage: UIImage?
    @State private var showPicker = false
    @State private var showShareSheet = false
    
    var body: some View {
        ZStack {
            // Градиентный фон
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Заголовок
                Text("Виртуальная примерка")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                    .padding(.top, 16)
                
                // Информация о выбранном дизайне
                VStack {
                    HStack {
                        Text("Выбранный дизайн")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        AsyncImage(url: design.imageURL) { phase in
                            switch phase {
                            case .empty: ProgressView()
                            case .success(let image): image.resizable().scaledToFit()
                            case .failure: Image(systemName: "exclamationmark.triangle").foregroundColor(.red)
                            @unknown default: EmptyView()
                            }
                        }
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                        
                        VStack(alignment: .leading) {
                            Text(design.name)
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white)
                            Text(design.description)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                VStack {
                    HStack {
                        Text(vm.resultImage == nil ? "Ваше фото" : "Результат")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    if vm.isLoading {
                        VStack {
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding()
                            Text("Обработка изображения...")
                                .foregroundColor(.white)
                        }
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    } else if let resultImage = vm.resultImage {
                        // Показываем результат
                        ZStack {
                            Image(uiImage: resultImage)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(12)
                            
                            VStack {
                                Spacer()
                                HStack {
                                    Button {
                                        // Сбросить результат и начать заново
                                        vm.resultImage = nil
                                    } label: {
                                        HStack {
                                            Image(systemName: "arrow.backward")
                                            Text("Назад")
                                        }
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 16)
                                        .background(Color.black.opacity(0.5))
                                        .cornerRadius(20)
                                        .foregroundColor(.white)
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        showShareSheet = true
                                    } label: {
                                        HStack {
                                            Image(systemName: "square.and.arrow.up")
                                            Text("Поделиться")
                                        }
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 16)
                                        .background(Color.black.opacity(0.5))
                                        .cornerRadius(20)
                                        .foregroundColor(.white)
                                    }
                                }
                                .padding()
                            }
                        }
                        .padding(.horizontal)
                    } else if let inputImage = inputImage {
                        ZStack {
                            Image(uiImage: inputImage)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(12)
                            
                            VStack {
                                Spacer()
                                HStack {
                                    Button {
                                        // Сбросить фото
                                        self.inputImage = nil
                                    } label: {
                                        HStack {
                                            Image(systemName: "xmark")
                                            Text("Другое фото")
                                        }
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 16)
                                        .background(Color.black.opacity(0.5))
                                        .cornerRadius(20)
                                        .foregroundColor(.white)
                                    }
                                }
                                .padding()
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        Button {
                            showPicker = true
                        } label: {
                            VStack {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 30))
                                    .padding(.bottom, 5)
                                Text("Сделать фото рук")
                            }
                            .padding()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                    }
                }
                
                if let _ = inputImage, let _ = design.imageURL, vm.resultImage == nil {
                    Button {
                        // Показать спиннер перед обработкой
                        withAnimation {
                            vm.isLoading = true
                        }
                        
                        // Добавим таймер на 1 секунду для отображения спиннера
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            vm.tryOnDesign(handImage: inputImage!, design: design)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Применить дизайн")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple, Color.blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .shadow(color: Color.purple.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal)
                }
                
                if let error = vm.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showPicker) {
            ImagePickerView(image: $inputImage)
        }
        .sheet(isPresented: $showShareSheet) {
            if let resultImage = vm.resultImage {
                ShareSheet(items: [resultImage])
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
