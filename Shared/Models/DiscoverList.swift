//
//  DiscoverResult.swift
//  Feedac Learn (iOS)
//
//  Created by Marius Ilie on 05/09/2020.
//

import Foundation

struct ReviewsDiscoverList: Codable {
    let reviews: [Review]
}

extension ReviewsDiscoverList {
    static func mock(_ count: Int, lessonId: String? = nil) -> ReviewsDiscoverList {
        return ReviewsDiscoverList(reviews: Review.mock(count, lessonId: lessonId))
    }
}

struct DiscoverList: Codable {
    let lessons: [Lesson]
}

extension DiscoverList {
    static func mock(_ count: Int, id: String? = nil, authorId: String? = nil) -> DiscoverList {
        return DiscoverList(lessons: Lesson.mock(count, id: id, authorId: authorId))
    }
}
