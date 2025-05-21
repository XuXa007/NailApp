import SwiftUI

struct EditDesignView: View {
    @ObservedObject var viewModel: MasterDesignsViewModel
    let design: NailDesign
    let username: String
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var description: String
    @State private var selectedColor: NailColor
    @State private var selectedType: DesignType
    @State private var selectedSeason: Season
    @State private var selectedLength: NailLength
    @State private var selectedMaterial: DesignMaterial
    @State private var showDeleteAlert = false
    
    init(viewModel: MasterDesignsViewModel, design: NailDesign, username: String) {
        self.viewModel = viewModel
        self.design = design
        self.username = username
        
        // Инициализируем State переменные
        _name = State(initialValue: design.name)
        _description = State(initialValue: design.description)
        
        // Находим соответствующие enum значения или используем значения по умолчанию
        _selectedColor = State(initialValue: design.nailColors.first ?? .pink)
        _selectedType = State(initialValue: design.type ?? .french)
        _selectedSeason = State(initialValue: design.season ?? .everyday)
        _selectedLength = State(initialValue: design.designLength ?? .medium)
        _selectedMaterial = State(initialValue: design.designMaterial ?? .gel)
    }
    
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
                        // Используем демо-изображение из ViewModel вместо AsyncImage
                        Image(uiImage: viewModel.imageForDesign(design))
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        
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
                        
                        HStack(spacing: 16) {
                            Button(action: {
                                showDeleteAlert = true
                            }) {
                                Text("Удалить")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.opacity(0.8))
                                    .cornerRadius(12)
                            }
                            
                            Button(action: {
                                Task {
                                    await updateDesign()
                                }
                            }) {
                                Text("Сохранить")
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
                            }
                        }
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
            .navigationTitle("Редактирование дизайна")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Удалить дизайн"),
                    message: Text("Вы уверены, что хотите удалить этот дизайн? Это действие нельзя отменить."),
                    primaryButton: .destructive(Text("Удалить")) {
                        Task {
                            await deleteDesign()
                        }
                    },
                    secondaryButton: .cancel(Text("Отмена"))
                )
            }
        }
    }
    
    private func updateDesign() async {
        // Создаем обновленный дизайн
        let updatedDesign = NailDesign(
            id: design.id,
            name: name,
            description: description,
            colors: [selectedColor.rawValue],
            designType: selectedType.rawValue,
            occasion: selectedSeason.rawValue,
            length: selectedLength.rawValue,
            material: selectedMaterial.rawValue,
            imagePath: design.imagePath,
            thumbnailPath: design.thumbnailPath,
            createdBy: design.createdBy,
            salonName: design.salonName
        )
        
        let success = await viewModel.updateDesign(updatedDesign, username: username)
        
        if success {
            dismiss()
        }
    }
    
    private func deleteDesign() async {
        let success = await viewModel.deleteDesign(id: design.id, username: username)
        
        if success {
            dismiss()
        }
    }
}
