//
//  TabBarView.swift
//  Feedac Learn (iOS)
//
//  Created by Marius Ilie on 05/09/2020.
//

import SwiftUI

struct TabBarView: View {
    @State var selectedTab = Tab.discover
    
    enum Tab: Int, CaseIterable {
        case discover
        case search
        case account
        
        var title: String {
            switch self {
            case .discover: return "Discover"
            case .search: return "Search"
            case .account: return "Account"
            default: return ""
            }
        }
        
        var image: Image {
            switch self {
            case .discover: return Image(systemName: "waveform.path.ecg")
            case .search: return Image(systemName: "magnifyingglass")
            case .account: return Image(systemName: "person.crop.circle")
            }
        }
        
        var view: some View {
            switch self {
            case .discover: return Image(systemName: "waveform.path.ecg")
            case .search: return Image(systemName: "magnifyingglass")
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
            Tab.discover.view.tabItem {
                self.tabBarItem(text: Tab.discover.title, image: Tab.discover.image)
            }.tag(Tab.discover.title)
            Tab.search.view.tabItem {
                self.tabBarItem(text: Tab.search.title, image: Tab.search.image)
            }.tag(Tab.search.title)
            Tab.account.view.tabItem {
                self.tabBarItem(text: Tab.account.title, image: Tab.account.image)
            }.tag(Tab.account.title)
        }
    }
}
