//
//  Lesson.swift
//  Feedac Learn (iOS)
//
//  Created by Marius Ilie on 05/09/2020.
//

import Foundation

struct Lesson: Codable, Identifiable {
    let id: String
    let teacherId: String
    let name: String
    let teacherName: String
    let imageUrl: URL?
    let joined: Bool
    let price: Double
    let maxAtendees: Int
    let productId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case teacherId = "id_prof"
        case name = "nume"
        case teacherName = "nume_prof"
        case imageUrl = "imagine"
        case joined
        case price = "pret_ora"
        case maxAtendees = "max_copii"
        case productId
    }
}

extension Lesson {
    static func mock(_ count: Int) -> [Lesson] {
        let randomDouble = Double.random(in: 0...100)
        let randomInt = Int.random(in: 0...30)
        return (1...count).map { data -> Lesson in
            Lesson(id: UUID().uuidString,
                   teacherId: UUID().uuidString,
                   name: UUID().uuidString,
                   teacherName: UUID().uuidString,
                   imageUrl: URL(string: "https://www.apple.com/leadership/images/bio/tim-cook_image.png.large.png")!,
                   joined: [true, false].randomElement()!,
                   price: randomDouble,
                   maxAtendees: randomInt,
                   productId: nil)
        }
    }
}
