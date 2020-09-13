//
//  LessonsViewList.swift
//  Feedac Learn
//
//  Created by Marius Ilie on 05.09.2020.
//

import SwiftUI
import Combine
import Feedac_CoreRedux
import Feedac_UIRedux

struct LessonViewList: ReduxView {
    @EnvironmentObject private var store: Store<AppState>
    @SwiftUI.State var searchObservable = TextFieldObservable()
    @SwiftUI.State var searchActive = false
    
    struct DataModel {
        let isLoading: Bool
        let criteria: String
        let headerLesson: String?
        let recentSearches: [String]
        let lessons: [String]
    }
    func map(_ state: AppState, dispatch: @escaping Dispatcher) -> DataModel {
        searchObservable.onUpdateText = nil
        searchObservable.onUpdateText = onUpdateText
        let lessons: (String?, [String]) = { () -> (String?, [String]) in
            let lessons = state.lessonsState.lessons.values.sorted { $0.rating > $1.rating }
            if state.lessonsState.criteria == "" {
                return (lessons.first?.id,
                        Array(lessons.dropFirst().prefix(3).map { $0.id }))
            } else {
                return (nil, Array(lessons.map { $0.id }))
            }
        }()
        return DataModel(isLoading: state.lessonsState.isLoading,
                         criteria: state.lessonsState.criteria,
                         headerLesson: lessons.0,
                         recentSearches: Array(state.lessonsState.recentSearches.filter { !$0.isEmpty }.prefix(3)),
                         lessons: lessons.1)
    }
    func onUpdateText(_ text: String) {
        store.dispatch(action: LessonsAction.FetchList(criteria: text))
        if text == "" {
            disableSearch()
        }
    }
    func disableSearch() {
        self.searchActive = false
    }
    func activateSearch() {
        self.searchActive = true
        store.dispatch(action: LessonsAction.SetList(isWaiting: false,
                                                     criteria: "",
                                                     clearData: true,
                                                     list: DiscoverList(lessons: [])))
    }
    
    func body(_ dataModel: DataModel) -> some View {
        VStack(alignment: .leading) {
            ScrollView {
                if searchActive || dataModel.criteria != "" {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Find your teacher")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top)
                            .padding(.top)
                            .padding(.horizontal)
                        Text("You can search for a course or field name. Also you can search for a teacher.")
                            .font(.body)
                            .padding(.horizontal)
                            .foregroundColor(Color.gray)
                        SearchField(text: $searchObservable.text,
                                    placeholder: "Search teachers...")
                            .padding(.horizontal)
                        Divider().padding(.horizontal)
                        Text("Recent Searches")
                            .fontWeight(.bold)
                            .foregroundColor(Color.gray.opacity(0.7))
                            .padding(.horizontal)
                        ForEach(dataModel.recentSearches, id: \.self) { criteria in
                            Text(criteria)
                                .foregroundColor(Color.gray.opacity(0.7))
                                .padding(.horizontal)
                                .onTapGesture {
                                    self.searchObservable.text = criteria
                                }
                        }
                        Divider().padding(.horizontal)
                    }
                }
                if dataModel.isLoading {
                    HStack {
                        Spacer()
                        Activitylndicator()
                            .frame(width: 20, height: 20)
                            .padding()
                        Spacer()
                    }.padding()
                } else {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        if let id = dataModel.headerLesson {
                            NavigationLink(destination: LessonDetailsView(authorSource: nil,
                                                                          lessonId: id)) {
                                HomeHeaderView(payButton: false,
                                               ignoreSafeArea: false,
                                               lessonId: id).padding()
                            }.drawingGroup()
                        }
                        ForEach(dataModel.lessons, id: \.self) { id in
                            NavigationLink(destination: LessonDetailsView(authorSource: nil,
                                                                          lessonId: id)) {
                                LessonView(authorSource: nil, lessonId: id)
                            }.drawingGroup()
                        }.padding(.horizontal)
                    }
                    if !searchActive {
                        ReadMoreHomePageBanner().onTapGesture {
                            withAnimation {
                                activateSearch()
                            }
                        }.drawingGroup()
                    }
                }
            }
        }.navigationBarItems(trailing: Button(action: {
            !searchActive && dataModel.criteria == "" ? activateSearch() : onUpdateText("")
        }) {
            Image(systemName: !searchActive && dataModel.criteria == "" ? "magnifyingglass" : "xmark")
        }.foregroundColor(.gray))
        .navigationBarTitleDisplayMode(!searchActive ? .automatic : .inline)
    }
}

struct LessonViewList_Previews: PreviewProvider {
    static var previews: some View {
        LessonViewList().environmentObject(AppCoordinator.sampleStore)
    }
}
