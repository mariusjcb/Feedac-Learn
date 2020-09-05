//
//  LessonView.swift
//  Feedac Learn (iOS)
//
//  Created by Marius Ilie on 05/09/2020.
//

import SwiftUI
import Feedac_CoreRedux
import Feedac_UIRedux

struct LessonView: ReduxView {
    struct DataModel {
        let lesson: Lesson
    }
    
    let lessonId: String
    
    func map(_ state: AppState, dispatch: @escaping Dispatcher) -> DataModel {
        DataModel(lesson: state.lessonsState.lessons[lessonId]!)
    }
    
    func body(_ dataModel: DataModel) -> some View {
        HStack {
            ZStack(alignment: .topLeading) {
                PosterImageView(
                    imageLoader: ImageLoaderCache.shared
                        .loaderFor(url: dataModel.lesson.imageUrl)
                )
                .background(Color.red)
                .cornerRadius(5)
                .frame(width: 150, height: 200)
                .clipped()
            }.fixedSize()
            VStack(alignment: .leading, spacing: 8) {
                Text(dataModel.lesson.name)
                    .font(.title)
                    .lineLimit(2)
                HStack {
                    Text(dataModel.lesson.teacherName)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
            }
        }.padding(.top, 8)
        .padding(.bottom, 8)
    }
}

struct LessonView_Previews: PreviewProvider {
    static var previews: some View {
        LessonView(lessonId: AppCoordinator.sampleStore.state.lessonsState.lessons.first!.value.id)
            .environmentObject(AppCoordinator.sampleStore)
    }
}
