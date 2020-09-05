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
        let criteria: String?
        
        func async(on state: State?, dispatch: @escaping Dispatcher) {
            DispatchQueue.global().asyncAfter(deadline: .now() + 5.0) {
                let response = DiscoverList
                    .mock(criteria == nil ? 10 : 100)
                dispatch(
                    SetList(criteria: criteria,
                            list: response)
                )
            }
        }
    }
    
    struct SetList: Action {
        let criteria: String?
        let list: DiscoverList
    }
}
