//
//  AppStateReducer.swift
//  Feedac Learn (iOS)
//
//  Created by Marius Ilie on 05/09/2020.
//

import Foundation
import Feedac_CoreRedux

let AppStateReducer: Reducer<AppState> = { state, action  in
    var state = state
    state.lessonsState = LessonsReducer(state.lessonsState, action)
    state.userState = UserReducer(state.userState, action)
    state.tabBarState = TabBarReducer(state.tabBarState, action)
    return state
}
