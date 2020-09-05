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
    internal static let store = Store<AppState>(AppState(),
                                                using: AppStateReducer,
                                                intercept: [AppLogger])
    
    let archiveScheduler: Timer
    
    init() {
        archiveScheduler = Timer
            .scheduledTimer(withTimeInterval: 10.0,
                            repeats: true,
                            block: { _ in
                                AppCoordinator.store.state.archiveState()
                            })
    }
    
    #if targetEnvironment(macCatalyst)
    var body: some Scene {
        WindowGroup {
            StoreProvider(store: Self.store) {
                SplitView()
            }
        }
    }
    #else
    var body: some Scene {
        WindowGroup {
            ReduxStoreUIContainer(Self.store) {
                TabBarView()
            }
        }
    }
    #endif
}

#if DEBUG
extension AppCoordinator {
    static var sampleStore = Store<AppState>(AppState(lessonsState: .sampleState), using: AppStateReducer)
}
#endif
