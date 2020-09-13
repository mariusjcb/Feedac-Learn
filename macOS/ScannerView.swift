//
//  ScannerView.swift
//  Feedac Learn App (iOS)
//
//  Created by Marius Ilie on 11.09.2020.
//

import SwiftUI

struct ScannerView: View {    
    var body: some View {
        Text("Can't scan QRCodes on this platform")
    }
}

struct LivestreamView: View {
    @Binding var sheetType: SheetType
    @State var isRecording = false
    
    var body: some View {
        Text("In progress...")
    }
}
