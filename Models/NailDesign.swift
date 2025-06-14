import Foundation


//  http://172.20.10.7:8080
//  http://192.168.1.8:8080

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
    let createdBy: String?
    let salonName: String?
    
    var nailColors: [NailColor] {
        colors.compactMap { NailColor(rawValue: $0.lowercased()) }
    }
    
    var style: NailStyle? { NailStyle(rawValue: designType.lowercased()) }
    var season: Season? { Season(rawValue: occasion.lowercased()) }
    var designLength: NailLength? { NailLength(rawValue: length.lowercased()) }
    var type: DesignType? { DesignType(rawValue: designType.lowercased()) }
    var designMaterial: DesignMaterial? { DesignMaterial(rawValue: material.lowercased()) }
    
    var imageURL: URL? {
        if imagePath.hasPrefix("http") {
            let updatedPath = imagePath.replacingOccurrences(of: "192.168.1.5", with: "172.20.10.7")
            return URL(string: updatedPath)
        }
        
        // Иначе формируем URL из базового + путь
        guard let base = Bundle.main.object(forInfoDictionaryKey: "ServerURL") as? String else {
            return nil
        }
        let trimmed = base.hasSuffix("/") ? String(base.dropLast()) : base
        return URL(string: "\(trimmed)/uploads/\(imagePath)")
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, name, description, colors
        case designType, occasion, length, material
        case imagePath, thumbnailPath
        case createdBy, salonName
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id            = try c.decode(String.self, forKey: .id)
        name          = try c.decode(String.self, forKey: .name)
        description   = try c.decode(String.self, forKey: .description)
        colors        = try c.decodeIfPresent([String].self, forKey: .colors) ?? []
        designType    = try c.decode(String.self, forKey: .designType)
        occasion      = try c.decode(String.self, forKey: .occasion)
        length        = try c.decode(String.self, forKey: .length)
        material      = try c.decode(String.self, forKey: .material)
        imagePath     = try c.decode(String.self, forKey: .imagePath)
        thumbnailPath = try c.decode(String.self, forKey: .thumbnailPath)
        createdBy     = try c.decodeIfPresent(String.self, forKey: .createdBy)
        salonName     = try c.decodeIfPresent(String.self, forKey: .salonName)
    }
    
    init(id: String, name: String, description: String, colors: [String],
         designType: String, occasion: String, length: String, material: String,
         imagePath: String, thumbnailPath: String, createdBy: String? = nil, salonName: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.colors = colors
        self.designType = designType
        self.occasion = occasion
        self.length = length
        self.material = material
        self.imagePath = imagePath
        self.thumbnailPath = thumbnailPath
        self.createdBy = createdBy
        self.salonName = salonName
    }
    
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
