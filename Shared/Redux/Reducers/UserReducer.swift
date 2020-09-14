//
//  UserReducer.swift
//  Feedac Learn
//
//  Created by Marius Ilie on 13.09.2020.
//

import Foundation
import Feedac_CoreRedux

let UserReducer: Reducer<UserState> = { state, action in
    var state = state
    switch action {
    case let action as UserAction.SetUser:
        state.currentUser = action.user
    case let action as UserAction.SetIsWaiting:
        state.isLoading = action.isWaiting
    case let action as UserAction.SetUserToken:
        state.token = action.token
    default: break
    }
    return state
}
