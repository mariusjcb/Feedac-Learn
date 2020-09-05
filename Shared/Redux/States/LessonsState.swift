//
//  LessonsState.swift
//  Feedac Learn (iOS)
//
//  Created by Marius Ilie on 05/09/2020.
//

import SwiftUI
import Feedac_CoreRedux

struct LessonsState: Feedac_CoreRedux.State, Codable {
    var lessons: [String: Lesson] = [:]
    
    var criteria: String?
    var recentSearches: [String] = []
    
    enum CodingKeys: String, CodingKey {
        case lessons, criteria, recentSearches
    }
}

#if DEBUG
extension LessonsState {
    static var sampleState: LessonsState {
        let lessons = Lesson.mock(100)
        var dict: [String: Lesson] = [:]
        for element in lessons {
            dict[element.id] = element
        }
        return LessonsState(lessons: dict, criteria: nil, recentSearches: ["demo", "search two", "last search"])
    }
}
#endif
