//
//  HomeHeaderView.swift
//  Feedac Learn
//
//  Created by Marius Ilie on 05.09.2020.
//

import SwiftUI
import Feedac_CoreRedux
import Feedac_UIRedux

public enum SheetType: Identifiable {
    case scan
    case code
    case livestreamBroadcast
    case livestreamView(URL?)
    
    public var id: Int {
        switch self {
        case .scan: return 1
        case .code: return 2
        case .livestreamBroadcast: return 3
        case .livestreamView: return 4
        }
    }
}

public struct HomeHeaderView: ReduxView {
    @SwiftUI.State var codeSheetType: SheetType = .code
    @SwiftUI.State var isSheetPresented: Bool = false
    @EnvironmentObject var store: Store<AppState>
    
    public struct DataModel {
        let lesson: Lesson?
    }
    
    let paymentHandler = PaymentHandler()
    let payButton: Bool
    let ignoreSafeArea: Bool
    let lessonId: String
    
    func buttonTitle(for dataModel: DataModel) -> String {
        if dataModel.lesson?.isOwnLesson == true {
            return "Start Now"
        } else if dataModel.lesson?.livePlaylistUrl != nil && dataModel.lesson?.joined == true {
            return "Jump in!"
        } else if dataModel.lesson?.joined == true {
            return "No Live"
        } else {
            return "Scan & Pay"
        }
    }
    
    func buttonIcon(for dataModel: DataModel) -> String {
        if dataModel.lesson?.livePlaylistUrl != nil, dataModel.lesson?.joined != nil {
            return "livephoto.play"
        } else {
            return "cart"
        }
    }
    
    func handleAction(for dataModel: DataModel) {
        isSheetPresented = true
        if dataModel.lesson?.isOwnLesson == true {
            codeSheetType = .livestreamBroadcast
        } else if let url = dataModel.lesson?.livePlaylistUrl, dataModel.lesson?.joined == true {
            codeSheetType = .livestreamView(url)
        } else {
            codeSheetType = .scan
        }
    }
    
    public func map(_ state: AppState, dispatch: @escaping Dispatcher) -> DataModel {
        DataModel(lesson: state.lessonsState.lessons[lessonId])
    }
    
    public func body(_ dataModel: DataModel) -> some View {
        ZStack(alignment: .bottomLeading) {
            if let lesson = dataModel.lesson {
                ZStack(alignment: .topLeading) {
                    ZStack(alignment: .bottomTrailing) {
                        HStack {
                            Spacer()
                            WebImageView(url: lesson.imageUrl?.absoluteString ?? "")
                                .zIndex(-1)
                                .scaledToFit()
                                .padding(.top, 8)
                                .padding(.trailing, ignoreSafeArea ? -110 : -60)
                                .clipped()
                        }
                    }.padding(.top, ignoreSafeArea ? 40 : 0)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lesson.name)
                            .font(.headline)
                            .foregroundColor(Color.primary)
                            .lineLimit(2)
                        Text("with \(lesson.teacherName)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.primary.opacity(0.5))
                            .lineLimit(1)
                    }.padding()
                    .padding(.top, ignoreSafeArea ? 80 : 0)
                }
                if !payButton {
                    Text("Learn Now")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.blue.opacity(0.8))
                        .padding(.bottom, ignoreSafeArea ? 20 : 0)
                        .lineLimit(1)
                        .padding()
                } else {
                    HStack(alignment: .center, spacing: 12) {
                        Button(action: {
                            handleAction(for: dataModel)
                        }) {
                            HStack {
                                Image(systemName: buttonIcon(for: dataModel))
                                Text(buttonTitle(for: dataModel))
                            }.padding(.vertical, 8)
                            .padding(.horizontal)
                            .background(Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        Button(action: {
                            isSheetPresented = true
                            codeSheetType = .code
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title3)
                                .foregroundColor(Color.blue.opacity(0.8))
                        }
                    }.padding()
                    .padding(.bottom, ignoreSafeArea ? 20 : 0)
                    .shadow(color: Color.black.opacity(0.15),
                            radius: 2, x: 0, y: 3)
                }
            } else {
                EmptyView()
            }
        }.drawingGroup()
        .clipped()
        .frame(height: 150 + (ignoreSafeArea ? 100 : 0), alignment: .leading).clipped()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.primary.opacity(0),
                                                       Color.secondary.opacity(0.2)]),
                           startPoint: .bottom,
                           endPoint: .top)
        ).cornerRadius(ignoreSafeArea ? 0 : 5)
        .shadow(color: Color.black.opacity(0.075), radius: 2, x: 0, y: 3)
        .sheet(isPresented: $isSheetPresented) {
            ZStack {
                CodeView(useAsScanner: $codeSheetType, isPresented: $isSheetPresented)
                LivestreamView(sheetType: $codeSheetType)
            }
        }
    }
}
