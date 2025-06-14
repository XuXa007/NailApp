import SwiftUI

struct DesignPickerView: View {
    @EnvironmentObject private var designsVM: DesignsViewModel
    @Binding var selectedDesign: NailDesign?
    @Environment(\.dismiss) private var dismiss
    @State private var filterShown = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Text("Выберите дизайн")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button {
                            filterShown = true
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    if designsVM.isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(2)
                            .tint(.white)
                        Spacer()
                    } else if designsVM.filteredDesigns.isEmpty {
                        Spacer()
                        Text("Дизайны не найдены")
                            .foregroundColor(.white)
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 16)], spacing: 16) {
                                ForEach(designsVM.filteredDesigns) { design in
                                    DesignCardView(design: design)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(
                                                    selectedDesign?.id == design.id ? Color.white : Color.clear,
                                                    lineWidth: 3
                                                )
                                        )
                                        .onTapGesture {
                                            selectedDesign = design
                                        }
                                }
                            }
                            .padding()
                        }
                    }
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Готово")
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
                            .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
            }
            .sheet(isPresented: $filterShown) {
                FilterView(
                    vm: FilterViewModel(
                        filter: designsVM.designFilter,
                        apply: { newFilter in
                            designsVM.designFilter = newFilter
                            designsVM.applyLocalFiltering()
                        }
                    )
                )
            }
            .onAppear {
                if designsVM.allDesigns.isEmpty {
                    Task {
                        await designsVM.loadDesigns()
                    }
                }
            }
        }
    }
}
