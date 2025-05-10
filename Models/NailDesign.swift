import Foundation

struct NailDesign: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let colors: [String]
    let designType: String
    let occasion: String
    let length: String
    let material: String
    let imagePath: String
    let thumbnailPath: String

    // вычисляемые для фильтра
    var nailColors: [NailColor] {
        colors.compactMap { NailColor(rawValue: $0.lowercased()) }
    }
    var style: NailStyle? { NailStyle(rawValue: designType.lowercased()) }
    var season: Season?    { Season(rawValue: occasion.lowercased()) }
    var type: DesignType?  { DesignType(rawValue: length.lowercased()) }

    var imageURL: URL? {
        guard let base = Bundle.main.object(forInfoDictionaryKey: "ServerURL") as? String else {
            return nil
        }
        let trimmed = base.hasSuffix("/") ? String(base.dropLast()) : base
        return URL(string: "\(trimmed)/api/images/\(imagePath)")
    }

    // MARK: — Custom Codable
    private enum CodingKeys: String, CodingKey {
        case id, name, description, colors
        case designType, occasion, length, material
        case imagePath, thumbnailPath
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id            = try c.decode(String.self, forKey: .id)
        name          = try c.decode(String.self, forKey: .name)
        description   = try c.decode(String.self, forKey: .description)
        // если colors = null, то decodeIfPresent вернёт nil → присвоим []
        colors        = try c.decodeIfPresent([String].self, forKey: .colors) ?? []
        designType    = try c.decode(String.self, forKey: .designType)
        occasion      = try c.decode(String.self, forKey: .occasion)
        length        = try c.decode(String.self, forKey: .length)
        material      = try c.decode(String.self, forKey: .material)
        imagePath     = try c.decode(String.self, forKey: .imagePath)
        thumbnailPath = try c.decode(String.self, forKey: .thumbnailPath)
    }

    // и не забудьте добавить пустой init, чтобы Codable был симметричным
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,            forKey: .id)
        try c.encode(name,          forKey: .name)
        try c.encode(description,   forKey: .description)
        try c.encode(colors,        forKey: .colors)
        try c.encode(designType,    forKey: .designType)
        try c.encode(occasion,      forKey: .occasion)
        try c.encode(length,        forKey: .length)
        try c.encode(material,      forKey: .material)
        try c.encode(imagePath,     forKey: .imagePath)
        try c.encode(thumbnailPath, forKey: .thumbnailPath)
    }
}
