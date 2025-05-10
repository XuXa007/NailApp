import Foundation

struct NailDesign: Identifiable, Codable {
    var id: Int
    var name: String
    var imageUrl: String
    var thumbnailUrl: String?
    var shape: String
    var length: String
    var occasion: String?
    var season: String?
    var color: String
    var decoration: String?
    var material: String?
    var tags: [String]?
    
    // Расширение для форматирования тегов
    var formattedTags: String {
        return tags?.joined(separator: ", ") ?? "Нет тегов"
    }
    
    // Создание демо-данных для предпросмотра
    static func demoDesigns() -> [NailDesign] {
        return [
            NailDesign(
                id: 1,
                name: "Классический красный",
                imageUrl: "https://example.com/red_nails.jpg",
                thumbnailUrl: "https://example.com/red_nails_thumb.jpg",
                shape: "Овальная",
                length: "Средние",
                occasion: "Повседневный",
                season: "Весна",
                color: "Красный",
                decoration: "Минимализм",
                material: "Гель-лак",
                tags: ["красный", "классика", "минимализм"]
            ),
            NailDesign(
                id: 2,
                name: "Свадебный французский",
                imageUrl: "https://example.com/wedding_nails.jpg",
                thumbnailUrl: "https://example.com/wedding_nails_thumb.jpg",
                shape: "Миндалевидная",
                length: "Длинные",
                occasion: "Свадебный",
                season: "Лето",
                color: "Белый",
                decoration: "Стразы",
                material: "Гель",
                tags: ["свадьба", "французский", "стразы"]
            ),
            NailDesign(
                id: 3,
                name: "Яркий летний",
                imageUrl: "https://example.com/summer_nails.jpg",
                thumbnailUrl: "https://example.com/summer_nails_thumb.jpg",
                shape: "Квадратная",
                length: "Короткие",
                occasion: "Праздничный",
                season: "Лето",
                color: "Желтый",
                decoration: "Градиент",
                material: "Гель-лак",
                tags: ["лето", "яркий", "градиент"]
            )
        ]
    }
}
