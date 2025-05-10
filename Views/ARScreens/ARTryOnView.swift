import SwiftUI

struct ARTryOnView: View {
    // Выбранный дизайн, если он передан
    var selectedDesign: NailDesign?
    
    // Состояния
    @State private var design: NailDesign?
    @State private var showDesignPicker = false
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var isProcessing = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Заголовок
            Text("Примерка дизайна")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top)
            
            // Основное изображение (результат или выбранное)
            ZStack {
                if let processedImage = processedImage {
                    // Показываем результат
                    Image(uiImage: processedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(15)
                } else if let selectedImage = selectedImage {
                    // Показываем выбранное изображение
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(15)
                        .overlay(
                            isProcessing ?
                            ProgressView()
                                .scaleEffect(2)
                                .frame(width: 100, height: 100)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(15)
                            : nil
                        )
                } else {
                    // Показываем заглушку
                    VStack {
                        Image(systemName: "hand.draw")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                            .foregroundColor(.gray)
                        
                        Text("Сделайте фото или загрузите изображение")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                }
            }
            .padding(.horizontal)
            
            // Кнопки выбора источника изображения
            HStack(spacing: 30) {
                // Кнопка камеры
                Button(action: {
                    // В демо-версии просто открываем фотогалерею
                    showImagePicker = true
                }) {
                    VStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 30))
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                        
                        Text("Камера")
                            .font(.caption)
                    }
                }
                
                // Кнопка галереи
                Button(action: {
                    showImagePicker = true
                }) {
                    VStack {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 30))
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                        
                        Text("Галерея")
                            .font(.caption)
                    }
                }
            }
            .padding()
            
            // Отображение выбранного дизайна
            if let design = design ?? selectedDesign {
                HStack {
                    AsyncImage(url: URL(string: design.imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)
                        case .failure:
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .frame(width: 60, height: 60)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text(design.name)
                            .font(.headline)
                        
                        Text("\(design.shape), \(design.color)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showDesignPicker = true
                    }) {
                        Text("Изменить")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.blue.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            } else {
                // Кнопка выбора дизайна
                Button(action: {
                    showDesignPicker = true
                }) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Выбрать дизайн")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            
            // Кнопка применить
            if let _ = selectedImage, (design != nil || selectedDesign != nil) {
                Button(action: applyDesign) {
                    HStack {
                        Image(systemName: "wand.and.stars.inverse")
                        Text("Применить дизайн")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isProcessing ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(isProcessing)
            }
            
            // Кнопки действий с результатом
            if let _ = processedImage {
                HStack(spacing: 40) {
                    // Сохранить
                    Button(action: saveToGallery) {
                        VStack {
                            Image(systemName: "square.and.arrow.down")
                                .font(.system(size: 24))
                                .foregroundColor(.blue)
                            
                            Text("Сохранить")
                                .font(.caption)
                        }
                    }
                    
                    // Поделиться
                    Button(action: shareResult) {
                        VStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 24))
                                .foregroundColor(.green)
                            
                            Text("Поделиться")
                                .font(.caption)
                        }
                    }
                    
                    // В избранное
                    if UserProfile.isLoggedIn, let design = design ?? selectedDesign {
                        Button(action: {
                            addToFavorites(designId: design.id)
                        }) {
                            VStack {
                                Image(systemName: "heart")
                                    .font(.system(size: 24))
                                    .foregroundColor(.red)
                                
                                Text("В избранное")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
        }
        .onAppear {
            if selectedDesign != nil {
                design = selectedDesign
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showDesignPicker) {
            MainDesignView(selectionMode: true) { selectedDesign in
                design = selectedDesign
                showDesignPicker = false
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Уведомление"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationBarTitle("Примерка", displayMode: .inline)
    }
    
    // Применение дизайна к изображению
    private func applyDesign() {
        guard let image = selectedImage, let design = design ?? selectedDesign else { return }
        
        isProcessing = true
        
        // Используем обычный сервис для обработки в demo-режиме
#if DEBUG
        ARImageProcessor.shared.processImage(image: image, designImage: UIImage(systemName: "circle.fill")!) { resultImage, error in
            DispatchQueue.main.async {
                isProcessing = false
                
                if let resultImage = resultImage {
                    processedImage = resultImage
                } else {
                    showAlert = true
                    alertMessage = error?.localizedDescription ?? "Не удалось применить дизайн"
                }
            }
        }
        return
#endif
        
        // Отправляем запрос к API для обработки изображения
        ApiService.shared.applyDesignToPhoto(photo: image, designId: design.id) { resultImage, error in
            DispatchQueue.main.async {
                isProcessing = false
                
                if let resultImage = resultImage {
                    processedImage = resultImage
                } else {
                    showAlert = true
                    alertMessage = error?.localizedDescription ?? "Не удалось применить дизайн"
                }
            }
        }
    }
    
    // Сохранение в галерею
    private func saveToGallery() {
        guard let image = processedImage else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        showAlert = true
        alertMessage = "Изображение сохранено в галерею"
    }
    
    // Поделиться результатом
    private func shareResult() {
        guard let image = processedImage else { return }
        
        let activityViewController = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true)
        }
    }
    
    // Добавление в избранное
    private func addToFavorites(designId: Int) {
        ApiService.shared.addToFavorites(designId: designId) { success, error in
            DispatchQueue.main.async {
                showAlert = true
                alertMessage = success ? "Дизайн добавлен в избранное" : "Не удалось добавить в избранное"
            }
        }
    }
}
