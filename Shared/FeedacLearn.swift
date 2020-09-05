//
//  Feedac_LearnApp.swift
//  Shared
//
//  Created by Marius Ilie on 04/09/2020.
//

import SwiftUI
import Feedac_CoreRedux
import Feedac_UIRedux

@main
struct AppCoordinator: App {
    public static let store = Store<AppState>(reducer: AppStateReducer,
                                middleware: [AppLogger],
                                state: AppState())
    
    let archiveScheduler: Timer
    
    init() {
        archiveScheduler = Timer
            .scheduledTimer(withTimeInterval: 10.0,
                            repeats: true,
                            block: { _ in
                                store.state.archiveState()
                            })
    }
    
    #if targetEnvironment(macCatalyst)
    var body: some Scene {
        WindowGroup {
            StoreProvider(store: store) {
                SplitView().accentColor(.steam_gold)
            }
        }
    }
    #else
    var body: some Scene {
        WindowGroup {
            ReduxStoreUIContainer(store) {
                TabBarView()
            }
        }
    }
    #endif
}
