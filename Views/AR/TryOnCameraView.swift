import SwiftUI

struct TryOnCameraView: View {
    @EnvironmentObject private var designsVM: DesignsViewModel
    @State private var selectedDesign: NailDesign?
    @State private var showDesignPicker = false
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Виртуальная примерка")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                    .padding(.top, 16)
                
                if let design = selectedDesign {
                    VStack {
                        HStack {
                            Text("Выбранный дизайн:")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button {
                                showDesignPicker = true
                            } label: {
                                Text("Изменить")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            if let url = design.imageURL {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .empty: ProgressView()
                                    case .success(let image): image.resizable().scaledToFit()
                                    case .failure: Color.red.opacity(0.3)
                                    @unknown default: EmptyView()
                                    }
                                }
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            VStack(alignment: .leading) {
                                Text(design.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(design.description)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                } else {
                    Button {
                        showDesignPicker = true
                    } label: {
                        VStack {
                            Image(systemName: "square.grid.2x2.fill")
                                .font(.system(size: 40))
                                .padding(.bottom, 8)
                            
                            Text("Выбрать дизайн")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 20) {
                    Text("Сделайте фото ваших рук или загрузите готовое изображение, чтобы примерить выбранный дизайн.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    Button {
                        if selectedDesign != nil {
                            showCamera = true
                        } else {
                            showDesignPicker = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 20))
                            
                            Text("Сделать фото")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.purple, .blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: Color.purple.opacity(0.3), radius: 8)
                        .padding(.horizontal)
                        .opacity(selectedDesign != nil ? 1.0 : 0.5)
                    }
                    .disabled(selectedDesign == nil)
                }
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showDesignPicker) {
            DesignPickerView(selectedDesign: $selectedDesign)
                .environmentObject(designsVM)
        }
        .sheet(isPresented: $showCamera) {
            if capturedImage != nil {
                if let design = selectedDesign {
                    ARTryOnView(design: design)
                }
            } else {
                CameraView(capturedImage: $capturedImage)
            }
        }
        .onChange(of: capturedImage) { newImage in
            if newImage != nil {
                showCamera = true
            }
        }
    }
}
