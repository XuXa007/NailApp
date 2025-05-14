import SwiftUI
import Combine

struct ARTryOnView: View {
    @StateObject private var vm = ARViewModel()
    @State private var inputImage: UIImage?
    @State private var showPicker = false
    @State private var selectedDesign: NailDesign?
    @State private var showDesignSelector = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack {
                    Text("Выбранный дизайн")
                        .font(.headline)
                    
                    if let design = selectedDesign {
                        HStack {
                            AsyncImage(url: design.imageURL) { phase in
                                switch phase {
                                case .empty: ProgressView()
                                case .success(let image): image.resizable().scaledToFit()
                                case .failure: Image(systemName: "exclamationmark.triangle").foregroundColor(.red)
                                @unknown default: EmptyView()
                                }
                            }
                            .frame(width: 100, height: 100)
                            .cornerRadius(8)
                            
                            VStack(alignment: .leading) {
                                Text(design.name)
                                    .font(.title3)
                                    .bold()
                                Text(design.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    } else {
                        Button("Выбрать дизайн") {
                            showDesignSelector = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.bottom)
                
                if vm.isLoading {
                    ProgressView("Обработка...")
                        .padding()
                } else if let resultImage = vm.resultImage {
                    Text("Результат примерки")
                        .font(.headline)
                    Image(uiImage: resultImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                } else {
                    VStack {
                        Text("Фото ваших рук")
                            .font(.headline)
                        
                        if let inputImage = inputImage {
                            Image(uiImage: inputImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(12)
                        } else {
                            Button("Сделать фото рук") {
                                showPicker = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
                
                if let _ = inputImage, let design = selectedDesign, let designURL = design.imageURL {
                    Button("Примерить дизайн") {
                        // Fixed: Properly unwrap the optional URL
                        vm.tryOnDesign(handImage: inputImage!, designURL: designURL)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .padding()
                }
                
                if let error = vm.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Примерка дизайна")
            .sheet(isPresented: $showPicker) {
                ImagePickerView(image: $inputImage)
            }
            .sheet(isPresented: $showDesignSelector) {
                DesignSelectorView(selectedDesign: $selectedDesign)
            }
        }
    }
}

struct DesignSelectorView: View {
    @EnvironmentObject var designsVM: DesignsViewModel
    @Binding var selectedDesign: NailDesign?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                    ForEach(designsVM.filteredDesigns) { design in
                        DesignCardView(design: design)
                            .onTapGesture {
                                selectedDesign = design
                                dismiss()
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("Выберите дизайн")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
        }
    }
}
