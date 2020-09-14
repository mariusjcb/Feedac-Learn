//
//  Feedac_Learn_App_ClipsApp.swift
//  Feedac Learn App Clips
//
//  Created by Marius Ilie on 07.09.2020.
//

import SwiftUI
import AppClip
import Feedac_UIRedux
import Feedac_CoreRedux

@main
struct Feedac_Learn_App_ClipsApp: App {
    @SwiftUI.State var lessonId: String?
    internal static let store = Store<AppState>(AppState(title: "PRODUCTION"),
                                                using: AppStateReducer,
                                                intercept: [AppLogger])
    
    func handleUserActivity(_ userActivity: NSUserActivity) {
        guard
            let incomingURL = userActivity.webpageURL,
            let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems
        else {
            return
        }
        
        if let lessonId = queryItems.first(where: { $0.name == "lessonId" })?.value {
            self.lessonId = lessonId
            Self.store.dispatch(action: LessonsAction.FetchLesson(lessonId: lessonId))
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if let lessonId = lessonId {
                    ReduxStoreUIContainer(Self.store) {
                        TextLesson(lessonId: lessonId)
                    }
                } else {
                    Text("123---")
                }
            }.onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleUserActivity)
        }
    }
}

struct TextLesson: ReduxView {
    @EnvironmentObject private var store: Store<AppState>
    
    public struct DataModel {
        let lesson: Lesson?
    }
    
    @SwiftUI.State var selectedPage: Int = 1
    let lessonId: String
    
    public func map(_ state: AppState, dispatch: @escaping Dispatcher) -> DataModel {
        return DataModel(lesson: state.lessonsState.lessons[lessonId])
    }
    
    public func body(_ dataModel: DataModel) -> some View {
        Group {
            if let lesson = dataModel.lesson {
                LessonDetailsView(authorSource: nil, lessonId: lesson.id)
            } else {
                VStack(alignment: .center, spacing: 20) {
                    VStack(alignment: .center, spacing: 10) {
                        Text("Feedac Learn").font(.largeTitle)
                        Text("AppClips Loading...").font(.headline)
                    }
                    HStack {
                        Spacer()
                        Activitylndicator()
                            .frame(width: 20, height: 20)
                            .padding()
                        Spacer()
                    }.padding()
                }
            }
        }
    }
}
