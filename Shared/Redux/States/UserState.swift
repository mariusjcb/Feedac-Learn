//
//  UserState.swift
//  Feedac Learn
//
//  Created by Marius Ilie on 13.09.2020.
//

import Foundation
import Feedac_CoreRedux

struct UserState: Feedac_CoreRedux.State, Codable {
    var currentUser: User?
    var token: String?
    var isLoading: Bool = false
    
    var isLoggedIn: Bool { token != nil }
    
    enum CodingKeys: String, CodingKey {
        case currentUser
        case token
    }
}

extension UserState {
    static var sampleState: UserState {
        return UserState(currentUser: User.mock(), token: UUID().uuidString, isLoading: false)
    }
}
