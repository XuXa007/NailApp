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
    
    init(viewModel: MasterDesignsViewModel, design: NailDesign, username: String) {
        self.viewModel = viewModel
        self.design = design
        self.username = username
        
        _name = State(initialValue: design.name)
        _description = State(initialValue: design.description)
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
                        // Изображение дизайна
                        if let url = design.imageURL {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(height: 200)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                case .failure:
                                    Color.gray.opacity(0.3)
                                        .overlay(Text("Изображение недоступно").foregroundColor(.white))
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(height: 200)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                        
                        Group {
                            TextField("Название", text: $name)
                                .textFieldStyle(FieldStyle())
                            
                            TextField("Описание", text: $description, axis: .vertical)
                                .textFieldStyle(FieldStyle())
                                .lineLimit(3...6)
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
                        
                        Button("Сохранить изменения") {
                            Task {
                                await updateDesign()
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal)
                        .disabled(viewModel.isLoading || !isFormValid)
                        .opacity((viewModel.isLoading || !isFormValid) ? 0.5 : 1.0)
                        .padding(.top)
                    }
                    .padding()
                }
                
                if viewModel.isLoading {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .overlay(
                            ProgressView()
                                .scaleEffect(2)
                                .tint(.white)
                        )
                }
            }
            .navigationTitle("Редактирование")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !description.isEmpty
    }
    
    private func updateDesign() async {
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
        
        let success = await viewModel.updateDesign(updatedDesign)
        
        if success {
            dismiss()
        }
    }
}
