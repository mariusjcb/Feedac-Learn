//
//  TabBarView.swift
//  Feedac Learn (iOS)
//
//  Created by Marius Ilie on 05/09/2020.
//

import SwiftUI
import Feedac_CoreRedux
import Feedac_UIRedux

struct TabBarView: ReduxView {
    @EnvironmentObject private var store: Store<AppState>
    
    struct DataModel {
        let selectedTab: Tab
    }
    
    enum Tab: Int, CaseIterable {
        case discover = 0
        case account = 1
        
        var title: String {
            switch self {
            case .discover: return "Discover"
            case .account: return "Account"
            }
        }
        
        var image: Image {
            switch self {
            case .discover: return Image(systemName: "waveform.path.ecg")
            case .account: return Image(systemName: "person.crop.circle")
            }
        }
    }
    
    func tabBarItem(text: String, image: Image) -> some View {
        VStack {
            image.imageScale(.large)
            Text(text)
        }
    }
    
    func map(_ state: AppState, dispatch: @escaping Dispatcher) -> DataModel {
        return DataModel(selectedTab: Tab(rawValue: state.tabBarState.selectedTab)!)
    }
    
    func body(_ dataModel: DataModel) -> some View {
        TabView(selection: Binding<Int>(get: { () -> Int in
            return dataModel.selectedTab.rawValue
        }, set: { tag in
            store.dispatch(action: TabBarAction.SelectTab(tag: tag))
        })) {
            HomeView().tabItem {
                self.tabBarItem(text: Tab.discover.title, image: Tab.discover.image)
            }.tag(Tab.discover.rawValue).edgesIgnoringSafeArea(.all)
            AccountView().tabItem {
                self.tabBarItem(text: Tab.account.title, image: Tab.account.image)
            }.tag(Tab.account.rawValue)
        }
    }
}
