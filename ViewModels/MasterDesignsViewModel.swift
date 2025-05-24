import Foundation
import SwiftUI

@MainActor
class MasterDesignsViewModel: ObservableObject {
    @Published var designs: [NailDesign] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Загрузка дизайнов мастера с сервера
    func loadDesigns() async {
        guard AuthService.shared.isAuthenticated else {
            print("Пользователь не аутентифицирован")
            errorMessage = "Требуется аутентификация"
            return
        }
        
        guard AuthService.shared.currentUser?.role == .master else {
            print("Пользователь не является мастером")
            errorMessage = "Доступ запрещен"
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let masterDesigns = try await ApiService.shared.getMasterDesigns()
            designs = masterDesigns
            errorMessage = nil
            print("Загружено дизайнов мастера: \(designs.count)")
        } catch AuthError.noToken {
            print("Нет токена аутентификации")
            errorMessage = "Сессия истекла"
        } catch {
            print("Ошибка загрузки дизайнов мастера: \(error)")
            errorMessage = "Не удалось загрузить дизайны: \(error.localizedDescription)"
        }
    }
    
    func uploadDesign(
        name: String,
        description: String,
        designType: String,
        color: String,
        occasion: String,
        length: String,
        material: String,
        image: UIImage
    ) async -> Bool {
        guard AuthService.shared.isAuthenticated else {
            print("Пользователь не аутентифицирован")
            errorMessage = "Требуется аутентификация"
            return false
        }
        
        guard AuthService.shared.currentUser?.role == .master else {
            print("Пользователь не является мастером")
            errorMessage = "Доступ запрещен"
            return false
        }
        
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
                image: imageData
            )
            
            // Добавляем новый дизайн в список
            designs.append(newDesign)
            errorMessage = nil
            print("Дизайн успешно добавлен: \(newDesign.name)")
            return true
        } catch AuthError.noToken {
            print("Нет токена аутентификации при добавлении дизайна")
            errorMessage = "Сессия истекла"
            return false
        } catch {
            print("Ошибка добавления дизайна: \(error)")
            errorMessage = "Не удалось добавить дизайн: \(error.localizedDescription)"
            return false
        }
    }
    
    func updateDesign(_ design: NailDesign) async -> Bool {
        guard AuthService.shared.isAuthenticated else {
            print("Пользователь не аутентифицирован")
            errorMessage = "Требуется аутентификация"
            return false
        }
        
        guard AuthService.shared.currentUser?.role == .master else {
            print("Пользователь не является мастером")
            errorMessage = "Доступ запрещен"
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let updatedDesign = try await ApiService.shared.updateDesign(design: design)
            
            // Обновляем дизайн в списке
            if let index = designs.firstIndex(where: { $0.id == design.id }) {
                designs[index] = updatedDesign
                errorMessage = nil
                print("Дизайн успешно обновлен: \(updatedDesign.name)")
            }
            return true
        } catch AuthError.noToken {
            print("Нет токена аутентификации при обновлении дизайна")
            errorMessage = "Сессия истекла"
            return false
        } catch {
            print("Ошибка обновления дизайна: \(error)")
            errorMessage = "Не удалось обновить дизайн: \(error.localizedDescription)"
            return false
        }
    }
    
    func deleteDesign(id: String) async -> Bool {
        guard AuthService.shared.isAuthenticated else {
            print("Пользователь не аутентифицирован")
            errorMessage = "Требуется аутентификация"
            return false
        }
        
        guard AuthService.shared.currentUser?.role == .master else {
            print("Пользователь не является мастером")
            errorMessage = "Доступ запрещен"
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await ApiService.shared.deleteDesign(id: id)
            
            // Удаляем дизайн из списка
            designs.removeAll { $0.id == id }
            errorMessage = nil
            print("Дизайн успешно удален: \(id)")
            return true
        } catch AuthError.noToken {
            print("Нет токена аутентификации при удалении дизайна")
            errorMessage = "Сессия истекла"
            return false
        } catch {
            print("Ошибка удаления дизайна: \(error)")
            errorMessage = "Не удалось удалить дизайн: \(error.localizedDescription)"
            return false
        }
    }
    
    // Принудительная перезагрузка дизайнов
    func refreshDesigns() async {
        await loadDesigns()
    }
    
    // Очистка ошибок
    func clearError() {
        errorMessage = nil
    }
    
    func getDesign(by id: String) -> NailDesign? {
        return designs.first { $0.id == id }
    }
    
    // Проверка, принадлежит ли дизайн текущему пользователю
    func canEditDesign(_ design: NailDesign) -> Bool {
        guard let currentUser = AuthService.shared.currentUser else { return false }
        return design.createdBy == currentUser.username
    }
}
