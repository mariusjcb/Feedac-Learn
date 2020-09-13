//
//  LessonsAction.swift
//  Feedac Learn (iOS)
//
//  Created by Marius Ilie on 05/09/2020.
//

import Foundation
import Feedac_CoreRedux

struct LessonsAction {
    struct FetchList: AsyncAction {
        let criteria: String
        
        func async(on state: State?, dispatch: @escaping Dispatcher) {
            dispatch(
                SetList(isWaiting: true,
                        criteria: criteria,
                        clearData: true,
                        list: DiscoverList(lessons: []))
            )
            DispatchQueue.global().asyncAfter(deadline: .now() + 3.0) {
                let response = DiscoverList
                    .mock(criteria.isEmpty ? 10 : 100)
                dispatch(
                    SetList(isWaiting: false,
                            criteria: criteria,
                            clearData: false,
                            list: response)
                )
            }
        }
    }
    
    struct FetchAuthorLessonsList: AsyncAction {
        let authorId: String
        
        func async(on state: State?, dispatch: @escaping Dispatcher) {
            dispatch(
                SetAuthorList(isWaiting: true,
                              authorId: authorId,
                              clearData: true,
                              list: DiscoverList(lessons: []))
            )
            DispatchQueue.global().asyncAfter(deadline: .now() + 3.0) {
                dispatch(
                    SetAuthorList(isWaiting: false,
                                  authorId: authorId,
                                  clearData: false,
                                  list: DiscoverList.mock(5, authorId: authorId))
                )
            }
        }
    }
    
    struct FetchLessonReviewsList: AsyncAction {
        let lessonId: String
        
        func async(on state: State?, dispatch: @escaping Dispatcher) {
            dispatch(
                SetReviewsList(isWaiting: true,
                               lessonId: lessonId,
                               clearData: true,
                               list: ReviewsDiscoverList(reviews: []))
            )
            DispatchQueue.global().asyncAfter(deadline: .now() + 3.0) {
                dispatch(
                    SetReviewsList(isWaiting: false,
                                   lessonId: lessonId,
                                   clearData: false,
                                   list: ReviewsDiscoverList.mock(5, lessonId: lessonId))
                )
            }
        }
    }
    
    struct SetList: Action {
        let isWaiting: Bool
        let criteria: String
        let clearData: Bool
        let list: DiscoverList
    }
    
    struct SetAuthorList: Action {
        let isWaiting: Bool
        let authorId: String
        let clearData: Bool
        let list: DiscoverList
    }
    
    struct SetReviewsList: Action {
        let isWaiting: Bool
        let lessonId: String
        let clearData: Bool
        let list: ReviewsDiscoverList
    }
}
