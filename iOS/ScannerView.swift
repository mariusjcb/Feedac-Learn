//
//  ScannerView.swift
//  Feedac Learn App (iOS)
//
//  Created by Marius Ilie on 11.09.2020.
//

import SwiftUI
import UIKit
import RoundCode

enum RCAlphabet: String {
    case appleUUID = "-ABCDEF0123456789"
    
    var coder: RCCoder {
        return RCCoder(configuration: RCCoderConfiguration(characters: self.rawValue, version: .custom(24)))
    }
}

class ScannerDelegate: RCCameraViewControllerDelegate {
    var parent: ScannerController?
    
    func cameraViewController(didFinishScanning message: String) {
        parent?.didReceiveMessage(message)
    }
}

struct ScannerController: UIViewControllerRepresentable {
    @Binding var paymentHandler: PaymentHandler
    @Binding var darkModeSelected: Int
    @Binding var presentStream: Bool
    static var delegate = ScannerDelegate()
    
    func makeUIViewController(context: Context) -> RCCameraViewController {
        let camera = RCCameraViewController()
        camera.coder = RCAlphabet.appleUUID.coder
        Self.delegate.parent = self
        camera.delegate = Self.delegate
        return camera
    }
    
    func updateUIViewController(_ uiViewController: RCCameraViewController, context: Context) { 
        uiViewController.coder.scanningMode = darkModeSelected == 0 ? .lightBackground : .darkBackground
        return
    }
    
    func didReceiveMessage(_ message: String) {
        paymentHandler.startPayment { _ in
            
        }
    }
}

struct ScannerView: View {
    @State var presentSheet = false
    @State var paymentHandler = PaymentHandler()
    @State var selectedTag = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScannerController(paymentHandler: $paymentHandler,
                              darkModeSelected: $selectedTag,
                              presentStream: $presentSheet)
            VStack(spacing: 15) {
                Text("Is dark mode active on source?")
                    .foregroundColor(.gray)
                Picker(selection: $selectedTag, label: Text("Mode")) {
                    Text("No").foregroundColor(.gray).tag(0)
                    Text("Yes").foregroundColor(.gray).tag(1)
                }.pickerStyle(SegmentedPickerStyle())
                .environment(\.colorScheme, .dark)
            }.padding(.horizontal).padding(40)
            .background(LinearGradient(gradient: .init(colors: [Color.black.opacity(0),
                                                                Color.black.opacity(0.7),
                                                                Color.black.opacity(1)]),
                                       startPoint: .top, endPoint: .bottom))
        }
    }
}
