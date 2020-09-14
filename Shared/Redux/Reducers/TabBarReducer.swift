//
//  TabBarReducer.swift
//  Feedac Learn
//
//  Created by Marius Ilie on 14.09.2020.
//

import Foundation
import Feedac_CoreRedux

let TabBarReducer: Reducer<TabBarState> = { state, action in
    var state = state
    switch action {
    case let action as TabBarAction.SelectTab:
        state.selectedTab = action.tag
    default: break
    }
    return state
}
