//
//  ScannerView.swift
//  Feedac Learn
//
//  Created by Marius Ilie on 10.09.2020.
//

import SwiftUI
import RoundCode
import SDWebImageSwiftUI

struct CodeView: View {
    @Environment(\.colorScheme) var scheme
    @Binding var useAsScanner: SheetType
    @Binding var isPresented: Bool
    @State private var isAnimating = false
    @State private var selection = 0
    
    var bgColor: Color { scheme == .light ? Color("qrBackground") : .black }
    let screenSize: CGFloat = UIScreen.main.bounds.width * 0.6
    let paddingRatio: CGFloat = -317 / 414
    let marginRatio: CGFloat = 63 / 414
    
    func code(for message: String,
              colors: [UIColor]) -> RCImage {
        var image = RCImage(message: message)
        image.size = screenSize
        image.isTransparent = true
        image.gradientType = .linear(angle: .pi)
        image.tintColors = colors
        return image
    }
    
    func encode(message: String) throws -> Image {
        let rawImage = code(for: message, colors: [UIColor(named: "qrColorLight")!,
                                                   UIColor(named: "qrColor")!])
        do {
            let encodedImage = try RCAlphabet.appleUUID.coder.encode(rawImage)
            return Image(uiImage: encodedImage)
        } catch {
            print(error)
            throw error
        }
    }
    
    func animatedImage() -> some View {
        AnimatedImage(url: URL(string: "https://feedac.com/siri.gif"))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(screenSize * paddingRatio)
            .opacity(isAnimating ? 1 : 0)
            .animation(.easeIn)
            .clipShape(Circle())
            .padding(screenSize * marginRatio)
            .onAppear { isAnimating = true }
    }
    
    var body: some View {
        Group {
            if useAsScanner.id == SheetType.scan.id {
                ScannerView()
            } else if useAsScanner.id == SheetType.code.id {
                ZStack(alignment: .bottom) {
                    HStack { Spacer() }
                        .padding(.top, 230)
                        .background(LinearGradient(gradient: .init(colors: [Color.secondary.opacity(0),
                                                                            Color("qrColor").opacity(0.3)]),
                                                   startPoint: .top, endPoint: .bottom))
                    ZStack(alignment: .top) {
                        VStack(spacing: 45) {
                            Spacer()
                            HStack {
                                Spacer()
                                ZStack(alignment: .center) {
                                    Group {
                                        (try? encode(message: UUID().uuidString.uppercased())) ?? Image(systemName: "img")
                                    }.rotationEffect(.degrees(270)).drawingGroup()
                                    if scheme == .light {
                                        animatedImage().colorInvert()
                                    } else {
                                        animatedImage()
                                    }
                                }.frame(width: screenSize, height: screenSize, alignment: .center)
                                Spacer()
                            }
                            VStack(spacing: 15) {
                                Text("Scan this Code")
                                    .font(.largeTitle)
                                    .foregroundColor(Color("qrColor"))
                                Text("Use this code to share the lesson.\nYou can present this code to your students for payments.")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color("qrColor"))
                                    .padding(.horizontal, 35)
                                    .font(.headline)
                                    .lineSpacing(3.5)
                                    .foregroundColor(Color("qrColorLight"))
                            }
                            Spacer()
                        }
                        ZStack(alignment: .topTrailing) {
                            HStack {
                                Spacer()
                                Text("Feedac Learn")
                                    .font(.title2)
                                    .foregroundColor(Color.primary)
                                Spacer()
                            }
                            Button(action: { withAnimation { isPresented = false } }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .opacity(0.8)
                            }.foregroundColor(Color.primary)
                        }.padding(.top, 25)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 240)
                        .background(LinearGradient(gradient: .init(colors: [Color.secondary.opacity(0),
                                                                            Color.secondary.opacity(0.3)]),
                                                   startPoint: .bottom, endPoint: .top))
                    }
                }.background(bgColor)
            } else {
                EmptyView()
            }
        }
    }
}
