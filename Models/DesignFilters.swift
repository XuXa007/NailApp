import Foundation

struct DesignFilters: Codable {
    var shape: String?
    var length: String?
    var occasion: String?
    var season: String?
    var color: String?
    var decoration: String?
    var material: String?
    
    // Доступные опции для каждого фильтра
    static let shapeOptions = ["Квадратная", "Овальная", "Миндалевидная", "Стилет", "Балерина"]
    static let lengthOptions = ["Короткие", "Средние", "Длинные", "Очень длинные"]
    static let occasionOptions = ["Повседневный", "Праздничный", "Свадебный", "Деловой", "Выпускной"]
    static let seasonOptions = ["Весна", "Лето", "Осень", "Зима"]
    static let colorOptions = ["Красный", "Розовый", "Белый", "Черный", "Синий", "Зеленый", "Желтый", "Фиолетовый", "Нюдовый"]
    static let decorationOptions = ["Глиттер", "Стразы", "Наклейки", "Рисунок", "Градиент", "Минимализм"]
    static let materialOptions = ["Гель-лак", "Акрил", "Гель", "Обычный лак"]
    
    // Преобразуем фильтры в параметры запроса
    func toQueryParameters() -> [String: String] {
        var params: [String: String] = [:]
        
        if let shape = shape { params["shape"] = shape }
        if let length = length { params["length"] = length }
        if let occasion = occasion { params["occasion"] = occasion }
        if let season = season { params["season"] = season }
        if let color = color { params["color"] = color }
        if let decoration = decoration { params["decoration"] = decoration }
        if let material = material { params["material"] = material }
        
        return params
    }
}
