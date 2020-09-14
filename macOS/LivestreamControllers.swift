//
//  LivestreamControllers.swift
//  Feedac Learn App (iOS)
//
//  Created by Marius Ilie on 14.09.2020.
//

import SwiftUI

struct LivestreamView: View {
    @Binding var isPresented: Bool
    @Binding var sheetType: SheetType
    @State var isRecording = false
    
    var body: some View {
        ZStack(alignment: .top) {
            if sheetType.id == SheetType.livestreamBroadcast.id {
                EmptyView()
            } else if sheetType.id == SheetType.livestreamView(nil).id {
                switch sheetType {
                case let SheetType.livestreamView(url):
                    EmptyView()
                default: EmptyView()
                }
            } else {
                EmptyView()
            }
        }
    }
}
