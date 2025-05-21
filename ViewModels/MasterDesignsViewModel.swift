import Foundation
import SwiftUI

@MainActor
class MasterDesignsViewModel: ObservableObject {
    @Published var designs: [NailDesign] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Ключ для хранения дизайнов мастера в UserDefaults
    private let masterDesignsKey = "master_designs"
    
    // Получение дизайнов мастера из UserDefaults
    private func getMasterDesigns(for username: String) -> [NailDesign] {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: masterDesignsKey + "_" + username) else {
            // Возвращаем демо-дизайн для быстрой демонстрации, если нет сохраненных
            if username == "demo_master" {
                return [
                    NailDesign(
                        id: "m1",
                        name: "Авторский френч",
                        description: "Уникальный дизайн французского маникюра",
                        colors: ["white", "pink"],
                        designType: "french",
                        occasion: "wedding",
                        length: "medium",
                        material: "gel",
                        imagePath: "local://design1.jpg",
                        thumbnailPath: "local://thumb1.jpg",
                        createdBy: username,
                        salonName: "Студия Nail Art"
                    )
                ]
            }
            return []
        }
        
        do {
            return try JSONDecoder().decode([NailDesign].self, from: data)
        } catch {
            print("Ошибка декодирования дизайнов мастера: \(error)")
            return []
        }
    }
    
    // Сохранение дизайнов мастера в UserDefaults
    private func saveMasterDesigns(_ designs: [NailDesign], for username: String) {
        let defaults = UserDefaults.standard
        do {
            let data = try JSONEncoder().encode(designs)
            defaults.set(data, forKey: masterDesignsKey + "_" + username)
        } catch {
            print("Ошибка кодирования дизайнов мастера: \(error)")
        }
    }
    
    // Загрузка дизайнов мастера
    func loadDesigns(username: String) {
        // Важное изменение: не используем async/await здесь, чтобы избежать зависания
        isLoading = true
        
        // Имитация небольшой задержки
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            // Получаем дизайны мастера
            self.designs = self.getMasterDesigns(for: username)
            self.isLoading = false
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
        
        // Имитация задержки для демонстрации
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Создаем уникальный ID
        let newId = "m\(Int.random(in: 100...9999))"
        
        // Создаем новый дизайн
        let newDesign = NailDesign(
            id: newId,
            name: name,
            description: description,
            colors: [color],
            designType: designType,
            occasion: occasion,
            length: length,
            material: material,
            imagePath: "local://design_\(newId).jpg",
            thumbnailPath: "local://thumb_\(newId).jpg",
            createdBy: username,
            salonName: AuthViewModel.shared.user?.salonName ?? "Демо Салон"
        )
        
        // Получаем текущие дизайны мастера
        var userDesigns = getMasterDesigns(for: username)
        
        // Добавляем новый дизайн
        userDesigns.append(newDesign)
        
        // Сохраняем обновленные дизайны
        saveMasterDesigns(userDesigns, for: username)
        
        // Обновляем список дизайнов в модели представления
        designs = userDesigns
        
        return true
    }
    
    // Обновление существующего дизайна
    func updateDesign(_ design: NailDesign, username: String) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        // Имитация задержки для демонстрации
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Получаем текущие дизайны мастера
        var userDesigns = getMasterDesigns(for: username)
        
        // Находим индекс дизайна для обновления
        if let index = userDesigns.firstIndex(where: { $0.id == design.id }) {
            userDesigns[index] = design
            
            // Сохраняем обновленные дизайны
            saveMasterDesigns(userDesigns, for: username)
            
            // Обновляем список дизайнов в модели представления
            designs = userDesigns
            
            return true
        }
        
        return false
    }
    
    // Удаление дизайна
    func deleteDesign(id: String, username: String) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        // Имитация задержки для демонстрации
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Получаем текущие дизайны мастера
        var userDesigns = getMasterDesigns(for: username)
        
        // Удаляем дизайн с указанным ID
        userDesigns.removeAll { $0.id == id }
        
        // Сохраняем обновленные дизайны
        saveMasterDesigns(userDesigns, for: username)
        
        // Обновляем список дизайнов в модели представления
        designs = userDesigns
        
        return true
    }
    
    // Генерация цвета для дизайна на основе ID
    func colorForDesign(_ id: String) -> Color {
        let hash = abs(id.hashValue)
        let red = Double(hash % 255) / 255.0
        let green = Double((hash / 255) % 255) / 255.0
        let blue = Double((hash / 255 / 255) % 255) / 255.0
        
        return Color(red: red, green: green, blue: blue)
    }
    
    // Создание изображения для дизайна (для демонстрации)
    func imageForDesign(_ design: NailDesign) -> UIImage {
        let size = CGSize(width: 300, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Фон с градиентом
            let color = UIColor(colorForDesign(design.id))
            
            // Создаем градиент
            let startColor = color.cgColor
            let endColor = UIColor.white.cgColor
            
            // Безопасное создание градиента
            if let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [startColor, endColor] as CFArray,
                locations: [0.0, 1.0]
            ) {
                context.cgContext.drawLinearGradient(
                    gradient,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: size.width, y: size.height),
                    options: []
                )
            } else {
                // Запасной вариант, если градиент не создался
                context.cgContext.setFillColor(UIColor.gray.cgColor)
                context.cgContext.fill(CGRect(origin: .zero, size: size))
            }
            
            // Добавляем текст с названием дизайна
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let nameAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]
            
            let nameRect = CGRect(x: 20, y: 80, width: size.width - 40, height: 40)
            (design.name).draw(with: nameRect, options: .usesLineFragmentOrigin, attributes: nameAttributes, context: nil)
        }
    }
}

// Расширение для конвертации Color в UIColor
extension UIColor {
    convenience init(_ color: Color) {
        let uiColor = UIColor(color)
        self.init(cgColor: uiColor.cgColor)
    }
}

// Расширение для получения UIColor из Color
extension Color {
    var uiColor: UIColor {
        UIColor(self)
    }
}
