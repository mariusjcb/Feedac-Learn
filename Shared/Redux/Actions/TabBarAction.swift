//
//  TabBarAction.swift
//  Feedac Learn
//
//  Created by Marius Ilie on 14.09.2020.
//

import Foundation
import Feedac_CoreRedux

struct TabBarAction {
    struct SelectTab: Action {
        let tag: Int
    }
}
