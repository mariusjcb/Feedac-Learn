//
//  UserAction.swift
//  Feedac Learn
//
//  Created by Marius Ilie on 13.09.2020.
//

import Foundation
import Feedac_CoreRedux

struct UserAction {
    struct LogIn: AsyncAction {
        let email: String
        let biometricToken: String
        
        func async(on state: State?, dispatch: @escaping Dispatcher) {
            dispatch(SetIsWaiting(isWaiting: true))
            DispatchQueue.global().asyncAfter(deadline: .now() + 3.0) {
                dispatch(SetIsWaiting(isWaiting: false))
                dispatch(SetUserToken(token: UUID().uuidString))
            }
        }
    }
    
    struct FetchCurrentUser: AsyncAction {
        func async(on state: State?, dispatch: @escaping Dispatcher) {
            dispatch(SetIsWaiting(isWaiting: true))
            DispatchQueue.global().asyncAfter(deadline: .now() + 3.0) {
                dispatch(SetIsWaiting(isWaiting: false))
                dispatch(SetUser(user: User.mock()))
            }
        }
    }
    
    struct SetIsWaiting: Action {
        let isWaiting: Bool
    }
    
    struct SetUserToken: Action {
        let token: String?
    }
    
    struct SetUser: Action {
        let user: User?
    }
}
