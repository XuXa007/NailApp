import Foundation
import SwiftUI

@MainActor
class MasterDesignsViewModel: ObservableObject {
    @Published var designs: [NailDesign] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var apiService = ApiService.shared
    
    func loadDesigns(username: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            designs = try await apiService.getMasterDesigns(username: username)
        } catch {
            errorMessage = "Ошибка загрузки дизайнов: \(error.localizedDescription)"
            print(error)
        }
        
        isLoading = false
    }
    
    func uploadDesign(name: String, description: String,
                     designType: String, color: String,
                     occasion: String, length: String,
                     material: String, image: UIImage,
                     username: String) async -> Bool {
        
        isLoading = true
        errorMessage = nil
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            errorMessage = "Ошибка преобразования изображения"
            isLoading = false
            return false
        }
        
        do {
            let newDesign = try await apiService.uploadDesign(
                name: name,
                description: description,
                designType: designType,
                color: color,
                occasion: occasion,
                length: length,
                material: material,
                image: imageData,
                username: username
            )
            
            designs.append(newDesign)
            isLoading = false
            return true
        } catch {
            errorMessage = "Ошибка загрузки дизайна: \(error.localizedDescription)"
            print(error)
            isLoading = false
            return false
        }
    }
    
    func updateDesign(_ design: NailDesign, username: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedDesign = try await apiService.updateDesign(design: design, username: username)
            
            // Обновляем дизайн в списке
            if let index = designs.firstIndex(where: { $0.id == updatedDesign.id }) {
                designs[index] = updatedDesign
            }
            
            isLoading = false
            return true
        } catch {
            errorMessage = "Ошибка обновления дизайна: \(error.localizedDescription)"
            print(error)
            isLoading = false
            return false
        }
    }
    
    func deleteDesign(id: String, username: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await apiService.deleteDesign(id: id, username: username)
            
            // Удаляем дизайн из списка
            designs.removeAll { $0.id == id }
            
            isLoading = false
            return true
        } catch {
            errorMessage = "Ошибка удаления дизайна: \(error.localizedDescription)"
            print(error)
            isLoading = false
            return false
        }
    }
}
