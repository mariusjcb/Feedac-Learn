//
//  LessonsReducer.swift
//  Feedac Learn
//
//  Created by Marius Ilie on 05/09/2020.
//

import Foundation
import Feedac_CoreRedux

let LessonsReducer: Reducer<LessonsState> = { state, action in
    var state = state
    switch action {
    case let action as LessonsAction.SetList:
        if action.clearData {
            state.lessons = [:]
        }
        state.isLoading = action.isWaiting
        state.criteria = action.criteria
        state.recentSearches.append(action.criteria)
        state.lessons = state.lessons.merged(with: action.list)
    case let action as LessonsAction.SetAuthorList:
        if action.clearData {
            state.fetchedAuthorLessons[action.authorId] = [String: Lesson]()
        }
        state.isAuthorLoading = action.isWaiting
        state.fetchedAuthorLessons[action.authorId] = state.fetchedAuthorLessons[action.authorId]?.merged(with: action.list)
    case let action as LessonsAction.SetReviewsList:
        if action.clearData {
            state.fetchedLessonReviews[action.lessonId] = [String: Review]()
        }
        state.isReviewPageLoading = action.isWaiting
        state.fetchedLessonReviews[action.lessonId] = state.fetchedLessonReviews[action.lessonId]?.merged(with: action.list)
    default: break
    }
    return state
}

// MARK: - Helpers

extension Dictionary where Key == String, Value == Lesson {
    func merged(with list: DiscoverList) -> [Key: Value] {
        return merged(with: list.lessons)
    }
    
    func merged(with array: [Lesson]) -> [Key: Value] {
        var merged = self
        for lesson in array {
            guard merged[lesson.id] == nil else { continue }
            merged[lesson.id] = lesson
        }
        return merged
    }
}

extension Dictionary where Key == String, Value == Review {
    func merged(with list: ReviewsDiscoverList) -> [Key: Value] {
        return merged(with: list.reviews)
    }
    
    func merged(with array: [Review]) -> [Key: Value] {
        var merged = self
        for review in array {
            guard merged[review.id] == nil else { continue }
            merged[review.id] = review
        }
        return merged
    }
}
