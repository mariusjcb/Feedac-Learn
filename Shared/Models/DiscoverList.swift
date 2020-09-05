//
//  DiscoverResult.swift
//  Feedac Learn (iOS)
//
//  Created by Marius Ilie on 05/09/2020.
//

import Foundation

struct DiscoverList: Codable {
    let lessons: [Lesson]
}

extension DiscoverList {
    static func mock(_ count: Int) -> DiscoverList {
        return DiscoverList(lessons: Lesson.mock(count))
    }
}
