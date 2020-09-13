//
//  TabBarView.swift
//  Feedac Learn (iOS)
//
//  Created by Marius Ilie on 05/09/2020.
//

import SwiftUI
import Feedac_CoreRedux

struct TabBarView: View {
    @EnvironmentObject private var store: Store<AppState>
    @SwiftUI.State var selectedTab = Tab.discover
    
    enum Tab: Int, CaseIterable {
        case discover
        case account
        
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
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView().tabItem {
                self.tabBarItem(text: Tab.discover.title, image: Tab.discover.image)
            }.tag(Tab.discover.title).edgesIgnoringSafeArea(.all)
            Text("").tabItem {
                self.tabBarItem(text: Tab.account.title, image: Tab.account.image)
            }.tag(Tab.account.title)
        }
    }
}
