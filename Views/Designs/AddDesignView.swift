import SwiftUI
import PhotosUI

struct AddDesignView: View {
    @ObservedObject var viewModel: MasterDesignsViewModel
    let username: String
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedColor = NailColor.pink
    @State private var selectedType = DesignType.french
    @State private var selectedSeason = Season.everyday
    @State private var selectedLength = NailLength.medium
    @State private var selectedMaterial = DesignMaterial.gel
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        } else {
                            Button(action: {
                                isImagePickerPresented = true
                            }) {
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.system(size: 40))
                                    Text("Выбрать изображение")
                                }
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                                .foregroundColor(.white)
                            }
                        }
                        
                        Group {
                            TextField("Название", text: $name)
                                .textFieldStyle(FieldStyle())
                            
                            TextField("Описание", text: $description)
                                .textFieldStyle(FieldStyle())
                                .frame(height: 100)
                        }
                        
                        Group {
                            VStack(alignment: .leading) {
                                Text("Цвет")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(NailColor.allCases) { color in
                                            ColorSelectorItem(color: color, isSelected: color == selectedColor) {
                                                selectedColor = color
                                            }
                                        }
                                    }
                                    .padding(.vertical, 8)
                                }
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Тип дизайна")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Picker("Тип дизайна", selection: $selectedType) {
                                    ForEach(DesignType.allCases) { type in
                                        Text(type.description).tag(type)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Сезон/Случай")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Picker("Сезон/Случай", selection: $selectedSeason) {
                                    ForEach(Season.allCases) { season in
                                        Text(season.description).tag(season)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Длина")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Picker("Длина", selection: $selectedLength) {
                                    ForEach(NailLength.allCases) { length in
                                        Text(length.description).tag(length)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Материал")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Picker("Материал", selection: $selectedMaterial) {
                                    ForEach(DesignMaterial.allCases) { material in
                                        Text(material.description).tag(material)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                        
                        Button(action: {
                            Task {
                                await saveDesign()
                            }
                        }) {
                            Text("Сохранить дизайн")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.purple, .blue]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.purple.opacity(0.3), radius: 5)
                                .opacity(isFormValid ? 1.0 : 0.5)
                        }
                        .disabled(!isFormValid || viewModel.isLoading)
                        .padding(.top)
                    }
                    .padding()
                    .disabled(viewModel.isLoading)
                    .overlay(
                        Group {
                            if viewModel.isLoading {
                                LoadingView()
                            }
                        }
                    )
                }
            }
            .navigationTitle("Добавить дизайн")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !description.isEmpty && selectedImage != nil
    }
    
    private func saveDesign() async {
        guard let image = selectedImage else { return }
        
        let success = await viewModel.uploadDesign(
            name: name,
            description: description,
            designType: selectedType.rawValue,
            color: selectedColor.rawValue,
            occasion: selectedSeason.rawValue,
            length: selectedLength.rawValue,
            material: selectedMaterial.rawValue,
            image: image,
            username: username
        )
        
        if success {
            dismiss()
        }
    }
}

struct ColorSelectorItem: View {
    let color: NailColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack {
            Circle()
                .fill(color.color)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                )
                .padding(4)
            
            Text(color.description)
                .font(.caption)
                .foregroundColor(.white)
        }
        .onTapGesture {
            action()
        }
    }
}
