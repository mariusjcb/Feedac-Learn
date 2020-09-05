//
//  SplitView.swift
//  Feedac Learn (iOS)
//
//  Created by Marius Ilie on 05/09/2020.
//

import SwiftUI

struct SplitView: View {
    @State var selectedMenu: OutlineMenu = .popular
    
    @ViewBuilder
    var body: some View {
        HStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    ForEach(OutlineMenu.allCases) { menu in
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
            selectedMenu.contentView
        }
    }
}
