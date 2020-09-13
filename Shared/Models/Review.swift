//
//  Review.swift
//  Feedac Learn
//
//  Created by Marius Ilie on 07.09.2020.
//

import Foundation

struct Review: Codable, Identifiable, Hashable {
    let id: String
    let lessonId: String
    let imageUrl: URL?
    let authorName: String
    let message: String
    let rating: Int
}

extension Review {
    static func mock(_ count: Int, lessonId: String? = nil) -> [Review] {
        let elements = (1...count).map { data -> Review in
            Review(id: UUID().uuidString,
                   lessonId: lessonId ?? UUID().uuidString,
                   imageUrl: URL(string: [
                    "https://www.apple.com/leadership/images/bio/tim-cook_image.png.large.png",
                    "https://www.apple.com/leadership/images/bio/craig_federighi_image.png"
                   ].randomElement()!)!,
                   authorName: "Arthur Rock",
                   message: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. \n\nIt has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                   rating: Int.random(in: 1...5))
        }
        return elements
    }
}
