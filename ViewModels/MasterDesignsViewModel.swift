import Foundation
import SwiftUI

@MainActor
class MasterDesignsViewModel: ObservableObject {
    @Published var designs: [NailDesign] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Загрузка дизайнов мастера с сервера
    func loadDesigns(username: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let masterDesigns = try await ApiService.shared.getMasterDesigns(username: username)
            designs = masterDesigns
            print("Загружено дизайнов мастера: \(designs.count)")
        } catch {
            print("Ошибка загрузки дизайнов мастера: \(error)")
            errorMessage = "Не удалось загрузить дизайны"
            designs = []
        }
    }
    
    // Добавление нового дизайна
    func uploadDesign(
        name: String,
        description: String,
        designType: String,
        color: String,
        occasion: String,
        length: String,
        material: String,
        image: UIImage,
        username: String
    ) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                errorMessage = "Не удалось обработать изображение"
                return false
            }
            
            let newDesign = try await ApiService.shared.uploadDesign(
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
            
            // Добавляем новый дизайн в список
            designs.append(newDesign)
            print("Дизайн успешно добавлен: \(newDesign.name)")
            return true
        } catch {
            print("Ошибка добавления дизайна: \(error)")
            errorMessage = "Не удалось добавить дизайн"
            return false
        }
    }
    
    // Обновление дизайна
    func updateDesign(_ design: NailDesign, username: String) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let updatedDesign = try await ApiService.shared.updateDesign(design: design, username: username)
            
            // Обновляем дизайн в списке
            if let index = designs.firstIndex(where: { $0.id == design.id }) {
                designs[index] = updatedDesign
                print("Дизайн успешно обновлен: \(updatedDesign.name)")
            }
            return true
        } catch {
            print("Ошибка обновления дизайна: \(error)")
            errorMessage = "Не удалось обновить дизайн"
            return false
        }
    }
    
    // Удаление дизайна
    func deleteDesign(id: String, username: String) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await ApiService.shared.deleteDesign(id: id, username: username)
            
            // Удаляем дизайн из списка
            designs.removeAll { $0.id == id }
            print("Дизайн успешно удален: \(id)")
            return true
        } catch {
            print("Ошибка удаления дизайна: \(error)")
            errorMessage = "Не удалось удалить дизайн"
            return false
        }
    }
}
