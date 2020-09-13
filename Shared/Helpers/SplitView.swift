//
//  SplitView.swift
//  Feedac Learn (iOS)
//
//  Created by Marius Ilie on 05/09/2020.
//

import SwiftUI

struct OutlineRow : View {
    let item: TabBarView.Tab
    @Binding var selectedMenu: TabBarView.Tab
    
    var isSelected: Bool {
        selectedMenu == item
    }
    
    var body: some View {
        HStack {
            Group {
                item.image
                    .imageScale(.large)
                    .foregroundColor(isSelected ? .secondary : .primary)
            }.frame(width: 40)
            Text(item.title)
                .font(.title)
                .foregroundColor(isSelected ? .secondary : .primary)
            }
            .padding()
            .onTapGesture {
                self.selectedMenu = self.item
            }
    }
}

struct SplitView: View {
    @State var selectedMenu = TabBarView.Tab.discover
    
    @ViewBuilder
    var body: some View {
        HStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    ForEach(TabBarView.Tab.allCases, id: \.self) { menu in
                        ZStack(alignment: .leading) {
                            OutlineRow(item: menu, selectedMenu: self.$selectedMenu)
                                .frame(height: 50)
                            if menu == self.selectedMenu {
                                Rectangle()
                                    .foregroundColor(Color.secondary.opacity(0.1))
                                    .frame(height: 50)
                            }
                        }
                    }
                }
                .padding(.top, 32)
                .frame(width: 300)
            }
            .background(Color.primary.opacity(0.1))
            HomeView()
        }
    }
}
