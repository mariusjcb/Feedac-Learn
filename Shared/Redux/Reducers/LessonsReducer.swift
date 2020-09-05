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
        state.criteria = action.criteria
        state.lessons = state.lessons.merged(with: action.list)
        if let searchCriteria = action.criteria {
            state.recentSearches.append(searchCriteria)
        }
    default: fatalError("\(action) NOT IMPLEMENTED!")
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
