//
//  LivestreamControllers.swift
//  Feedac Learn App (iOS)
//
//  Created by Marius Ilie on 14.09.2020.
//

import SwiftUI
import UIKit
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
    @Binding var isWhiteboardEnabled: Bool
    
    func makeUIViewController(context: Context) -> LivestreamViewController {
        let controller = LivestreamViewController()
        controller.usesWhiteboard = isWhiteboardEnabled
        return controller
    }
    
    func updateUIViewController(_ uiViewController: LivestreamViewController, context: Context) {
//        uiViewController.setRecording(isRecording)
    }
}

struct LivestreamViewContainer: View {
    @Binding var isPresented: Bool
    @Binding var isWhiteboardEnabled: Bool
    
    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                HStack {
                    Spacer()
                    Text("You are streaming...")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(Color.white)
                    Spacer()
                }
                Button(action: { withAnimation { isPresented = false } }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .opacity(0.8)
                }.foregroundColor(Color.white)
            }.padding(.top, 30)
            .padding(.bottom, 8)
            .padding(.horizontal, 20)
            .background(Color.green)
            LivestreamCameraView(isWhiteboardEnabled: $isWhiteboardEnabled)
        }.edgesIgnoringSafeArea(.all)
    }
}

struct GradientButtonStyle: ButtonStyle {
    var textColor: Color
    var bgFrom: Color
    var bgTo: Color
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [bgFrom, bgTo]),
                                       startPoint: .leading, endPoint: .trailing))
            .cornerRadius(15.0)
    }
}

struct LivestreamView: View {
    @Binding var isPresented: Bool
    @Binding var sheetType: SheetType
    @State var isLivestreamPresented: Bool = false
    @State var isPresentingWhiteboard: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            if sheetType.id == SheetType.livestreamBroadcast.id {
                ZStack(alignment: .topTrailing) {
                    HStack {
                        Spacer()
                        Text("Feedac Learn")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(Color.primary)
                        Spacer()
                    }
                    Button(action: { withAnimation { isPresented = false } }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .opacity(0.8)
                    }.foregroundColor(Color.primary)
                }.padding(.top, 30)
                .padding(.bottom, 8)
                .padding(.horizontal, 20)
                VStack(spacing: 20) {
                    Spacer()
                    Button(action: {
                        isLivestreamPresented = true
                        isPresentingWhiteboard = true
                    }) {
                        HStack(alignment: .center, spacing: 20) {
                            Image(systemName: "hand.draw.fill").font(.title)
                                .padding(.leading)
                            Text("Live Whiteboard").font(.title).fontWeight(.bold)
                                .padding(.trailing)
                        }
                    }.buttonStyle(GradientButtonStyle(textColor: .white, bgFrom: .red, bgTo: .blue))
                    Text("or try...")
                    Button(action: {
                        isLivestreamPresented = true
                        isPresentingWhiteboard = false
                    }) {
                        HStack(alignment: .center, spacing: 20) {
                            Image(systemName: "video.fill").font(.title2)
                                .padding(.leading).foregroundColor(Color.primary.opacity(0.6))
                            Text("Live Streaming").font(.title2).fontWeight(.bold)
                                .padding(.trailing).foregroundColor(Color.primary.opacity(0.6))
                        }
                    }.buttonStyle(GradientButtonStyle(textColor: .primary,
                                                      bgFrom: Color.gray.opacity(0.3),
                                                      bgTo: Color.gray.opacity(0)))
                    .cornerRadius(15)
                    .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0),
                                                                                   Color.gray.opacity(0.15)]),
                                                       startPoint: .leading, endPoint: .trailing),
                                        lineWidth: 1))
                    Spacer()
                }.padding().padding()
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
        }.fullScreenCover(isPresented: $isLivestreamPresented) {
            LivestreamViewContainer(isPresented: $isLivestreamPresented,
                                    isWhiteboardEnabled: $isPresentingWhiteboard)
        }
    }
}
