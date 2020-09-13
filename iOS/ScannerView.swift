//
//  ScannerView.swift
//  Feedac Learn App (iOS)
//
//  Created by Marius Ilie on 11.09.2020.
//

import SwiftUI
import UIKit
import RoundCode
import AVKit

class LivestreamViewController: CameraViewController {
}

struct HLSPlayerElement: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> PlayerViewController {
        return PlayerViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: PlayerViewController, context: Context) { }
}

struct HLSPlayerView: View {
    let url: URL
    
    var body: some View {
        HLSPlayerElement(url: url).edgesIgnoringSafeArea(.all)
    }
}

struct LivestreamCameraView: UIViewControllerRepresentable {
    @Binding var isRecording: Bool
    
    func makeUIViewController(context: Context) -> LivestreamViewController {
        return LivestreamViewController()
    }
    
    func updateUIViewController(_ uiViewController: LivestreamViewController, context: Context) {
//        uiViewController.setRecording(isRecording)
    }
}

struct LivestreamView: View {
    @Binding var sheetType: SheetType
    @State var isRecording = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if sheetType.id == SheetType.livestreamBroadcast.id {
                LivestreamCameraView(isRecording: $isRecording)
                Button(action: { isRecording.toggle() }) {
                    Image(systemName: "\(isRecording ? "stop" : "record").circle").resizable()
                        .frame(width: 44.0, height: 44.0)
                        .padding(30)
                        .foregroundColor(Color.white)
                        .shadow(color: Color.black, radius: 5, x: 0, y: 4)
                }
            } else if sheetType.id == SheetType.livestreamView(nil).id {
                switch sheetType {
                case let SheetType.livestreamView(url):
                    if let url = url {
                        HLSPlayerView(url: url)
                    } else {
                        EmptyView()
                    }
                default: EmptyView()
                }
            } else {
                EmptyView()
            }
        }
    }
}

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
