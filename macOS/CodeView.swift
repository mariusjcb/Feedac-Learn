//
//  CodeView.swift
//  Feedac Learn
//
//  Created by Marius Ilie on 10.09.2020.
//

import SwiftUI

struct CodeView: View {
    @Binding var useAsScanner: SheetType
    @Binding var isPresented: Bool
    
    var body: some View {
        Text("Can't present QRCodes on this platform")
            .alert(isPresented: $isPresented) {
                Alert(title: Text("Error"),
                      message: Text("Your device doesn't support smart QR Codes."),
                      dismissButton: .default(Text("OK")))
            }
    }
}
