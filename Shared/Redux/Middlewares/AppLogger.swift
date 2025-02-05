//
//  LogMiddlewareProtocol.swift
//  Feedac Learn (iOS)
//
//  Created by Marius Ilie on 05/09/2020.
//

import Foundation
import Feedac_CoreRedux

let AppLogger: Middleware<AppState> = { dispatch, state in
    return { next in
        return { action in
            print("Action Dispatched: \(String(reflecting: type(of: action))) : \(String(describing: action))")
            return next(action)
        }
    }
}
