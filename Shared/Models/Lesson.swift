//
//  Lesson.swift
//  Feedac Learn (iOS)
//
//  Created by Marius Ilie on 05/09/2020.
//

import Foundation

public struct Lesson: Codable, Identifiable, Hashable {
    public let id: String
    public let teacherId: String
    public let name: String
    public let teacherName: String
    public let imageUrl: URL?
    public let joined: Bool
    public let isOwnLesson: Bool
    public let price: Double
    public let maxAtendees: Int
    public let productId: String?
    public let teacherDetails: String
    public let details: String
    public let rating: Int
    public let livePlaylistUrl: URL?
    
    var stringPriceSymbol: String { "RON" }
    var stringPriceValue: String { .init(format: "%.2f", price ?? 0) }
    var stringPrice: String { stringPriceSymbol + " " + stringPriceValue }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.finalize()
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case teacherId = "id_prof"
        case isOwnLesson
        case name = "nume"
        case teacherName = "nume_prof"
        case imageUrl = "imagine"
        case joined
        case price = "pret_ora"
        case maxAtendees = "max_copii"
        case productId
        case teacherDetails
        case details
        case rating
        case livePlaylistUrl
    }
}

extension Lesson {
    static func mock(_ count: Int, id: String? = nil, authorId: String? = nil) -> [Lesson] {
        let randomDouble = Double.random(in: 0...100)
        let randomInt = Int.random(in: 0...30)
        var iterator = -1
        let elements = (1...count).map { data -> Lesson in
            iterator += 1
            return Lesson(id: id ?? UUID().uuidString,
                          teacherId: authorId ?? UUID().uuidString,
                          name: ["Matematici Aplicate", "Compilatoare", "Tehnici de Compilare", "Matematica BAC M1", "Romana"][iterator % 5],
                          teacherName: ["Marius Ilie", "Radu Gramatovici", "Stefan Pavel", "Cezara Benegui", "Dan Dragulici"][iterator % 5],
                          imageUrl: URL(string: [
                            "https://feedac.com/img3.png",
                            "https://www.apple.com/leadership/images/bio/craig_federighi_image.png",
                            "https://www.apple.com/leadership/images/bio/tim-cook_image.png.large.png",
                            "https://feedac.com/img.png"
                          ][iterator % 4]),
                          joined: [true, false].randomElement()!,
                          isOwnLesson: [true, false].randomElement()!,
                          price: randomDouble,
                          maxAtendees: randomInt,
                          productId: nil,
                          teacherDetails: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. \n\nIt has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                          details: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. \n\nIt has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                          rating: [5, 4, 3, 2, 1][iterator % 5],
                          livePlaylistUrl: URL(string: "http://192.168.0.187/playlist.m3u8"))
        }
        return elements
    }
}
