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
    var fetchedAuthorLessons: [String: [String: Lesson]] = [:]
    var fetchedLessonReviews: [String: [String: Review]] = [:]
    
    var criteria: String
    var recentSearches: [String] = []
    
    var isLoading: Bool = false
    var isAuthorLoading: Bool = false
    var isReviewPageLoading: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case lessons, criteria, recentSearches
    }
}

//#if DEBUG
extension LessonsState {
    static var sampleState: LessonsState {
        let lessons = Lesson.mock(5)
        var dict: [String: Lesson] = [:]
        for element in lessons {
            dict[element.id] = element
        }
        return LessonsState(lessons: dict,
                            fetchedLessonReviews: [:],
                            criteria: "",
                            recentSearches: ["demo", "search two", "last search"])
    }
}
//#endif
