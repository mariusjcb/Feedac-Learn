//
//  LessonDetailsView.swift
//  Feedac Learn
//
//  Created by Marius Ilie on 06.09.2020.
//

import SwiftUI
import Feedac_CoreRedux
import Feedac_UIRedux
import LocalAuthentication

public struct LessonDetailsView: ReduxView {
    @EnvironmentObject private var store: Store<AppState>
    
    public struct DataModel {
        let lesson: Lesson?
        let otherLessons: [Lesson]
        let reviews: [Review]
        let hasLoadingReviews: Bool
        let hasLoadingLessons: Bool
    }
    
    @SwiftUI.State var selectedPage: Int = 1
    let authorSource: String?
    let lessonId: String
    
    public func map(_ state: AppState, dispatch: @escaping Dispatcher) -> DataModel {
        guard let lessonsSource = authorSource != nil ?
                state.lessonsState.fetchedAuthorLessons[authorSource!] :
                state.lessonsState.lessons else {
            return DataModel(lesson: nil,
                             otherLessons: [],
                             reviews: [],
                             hasLoadingReviews: state.lessonsState.isReviewPageLoading,
                             hasLoadingLessons: state.lessonsState.isAuthorLoading)
        }
        let lesson = lessonsSource[lessonId]
        let others = Array({ () -> [String: Lesson] in
            if let lesson = lesson {
                return state.lessonsState.fetchedAuthorLessons[lesson.teacherId] ?? [:]
            } else { return [:] }
        }().values)
        let reviews = Array({ () -> [String: Review] in
            if let lesson = lesson {
                return state.lessonsState.fetchedLessonReviews[lesson.id] ?? [:]
            } else { return [:] }
        }().values)
        return DataModel(lesson: lesson,
                         otherLessons: others,
                         reviews: reviews,
                         hasLoadingReviews: state.lessonsState.isReviewPageLoading,
                         hasLoadingLessons: state.lessonsState.isAuthorLoading)
    }
    
    func renderFirstPage(for dataModel: DataModel) -> some View {
        let model = "\(dataModel.lesson!.stringPriceValue)\n\(dataModel.lesson!.stringPriceSymbol)"
        return LazyVStack {
            DetailsView(title: "Course Details",
                        content: dataModel.lesson!.teacherDetails,
                        rightContent: model,
                        showRating: true,
                        rating: dataModel.lesson!.rating)
                .padding(.bottom, 25)
            DetailsView(title: "Teacher Details",
                        content: dataModel.lesson!.teacherDetails)
        }.padding()
        .padding(.horizontal, 4)
    }
    
    func renderPage2(for dataModel: DataModel) -> some View {
        LazyVStack(alignment: .leading, spacing: 8) {
            if dataModel.hasLoadingLessons {
                HStack {
                    Spacer()
                    Activitylndicator()
                        .frame(width: 20, height: 20)
                        .padding()
                    Spacer()
                }.padding()
            } else {
                ForEach(dataModel.otherLessons, id: \.self) { obj in
                    NavigationLink(destination: LessonDetailsView(authorSource: obj.teacherId,
                                                                  lessonId: obj.id)) {
                        LessonView(showAuthor: false,
                                   authorSource: obj.teacherId,
                                   lessonId: obj.id)
                            .onAppear(perform: {
                                store.dispatch(action: LessonsAction
                                                .FetchLesson(changeIsWaiting: false,
                                                             lessonId: obj.id))
                            })
                    }.drawingGroup()
                }.padding(.top, 25)
                .padding(.horizontal)
                .padding(.horizontal)
            }
        }.onAppear {
            guard let lesson = dataModel.lesson else { return }
            store.dispatch(action: LessonsAction.FetchAuthorLessonsList(authorId: lesson.teacherId))
        }.padding(.bottom, 40)
    }
    
    func renderPage3(for dataModel: DataModel) -> some View {
        LazyVStack(alignment: .leading, spacing: 8) {
            if dataModel.hasLoadingReviews {
                HStack {
                    Spacer()
                    Activitylndicator()
                        .frame(width: 20, height: 20)
                        .padding()
                    Spacer()
                }.padding()
            } else {
                ForEach(dataModel.reviews, id: \.self) { obj in
                    VStack(alignment: .leading) {
                        ReviewRow(lessonSource: obj.lessonId, reviewId: obj.id).drawingGroup()
                        Divider().padding(.top, 12).padding(.horizontal, 4)
                    }
                }.padding(.top, 15)
                .padding(.horizontal)
            }
        }.onAppear {
            guard let lesson = dataModel.lesson else { return }
            store.dispatch(action: LessonsAction.FetchLessonReviewsList(lessonId: lesson.id))
        }.padding(.bottom, 40)
    }
    
    public func body(_ dataModel: DataModel) -> some View {
        Group {
            if let lesson = dataModel.lesson {
                VStack {
                    ZStack(alignment: .bottom) {
                        HomeHeaderView(payButton: true,
                                       ignoreSafeArea: true,
                                       lessonId: lessonId)
                            .padding(.bottom, 15)
                        VStack(spacing: 100) {
                            Picker(selection: $selectedPage,
                                   label: Text("Select...")) {
                                Text("About").tag(1)
                                Text("Other Lessons").tag(2)
                                Text("Reviews").tag(3)
                            }.pickerStyle(SegmentedPickerStyle())
                        }.background(Color("lightGray"))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 3)
                    }
                    ScrollView {
                        Group {
                            if selectedPage == 1 {
                                renderFirstPage(for: dataModel)
                            } else if selectedPage == 2 {
                                renderPage2(for: dataModel)
                            } else if selectedPage == 3 {
                                renderPage3(for: dataModel)
                            }
                        }.padding(.bottom, 100)
                    }
                }
            } else {
                EmptyView()
            }
        }.edgesIgnoringSafeArea(.all)
        .navigationBarTitleDisplayMode(.large)
    }
}
