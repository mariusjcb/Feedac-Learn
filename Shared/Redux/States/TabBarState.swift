//
//  TabBarState.swift
//  Feedac Learn
//
//  Created by Marius Ilie on 13.09.2020.
//

import Foundation
import Feedac_CoreRedux

struct TabBarState: Feedac_CoreRedux.State, Codable {
    var selectedTab: Int = 0
}
