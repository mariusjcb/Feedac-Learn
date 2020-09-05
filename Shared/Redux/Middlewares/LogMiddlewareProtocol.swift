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
            #if DEBUG
            print("Action Dispatched: \(String(reflecting: type(of: action))) for state: \(String(describing: state()))")
            #endif
            
            return next(action)
        }
    }
}
