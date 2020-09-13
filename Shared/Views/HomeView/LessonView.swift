//
//  LessonView.swift
//  Feedac Learn (iOS)
//
//  Created by Marius Ilie on 05/09/2020.
//

import SwiftUI
import Combine
import Feedac_CoreRedux
import Feedac_UIRedux

public struct Activitylndicator: View {
    let style = StrokeStyle(lineWidth: 6, lineCap: . round)
    @SwiftUI.State var animate = false
    
    let colorl = Color.gray.opacity(0.5)
    let color2 = Color.gray.opacity(0.2)
    
    public var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    AngularGradient(gradient: .init(colors: [colorl, color2]), center: .center),
                    style: style
                ).rotationEffect(Angle(degrees: animate ? 360 : 0))
                .animation(Animation.linear(duration: 0.7).repeatForever(autoreverses: false))
                .onAppear( ) { self.animate.toggle() }
        }.animation(.none)
    }
}
public struct SearchField: View {
    @Binding var text: String
    var placeholder: String = ""
    
    public var body: some View {
        HStack {
            TextField(placeholder, text: $text)
            if text != "" {
                Image(systemName: "xmark.circle.fill")
                    .imageScale(.medium)
                    .foregroundColor(Color.primary.opacity(0.7))
                    .padding(3)
                    .onTapGesture {
                        withAnimation {
                            text = ""
                        }
                    }
            }
        }.padding(10)
        .background(Color("lightGray"))
        .cornerRadius(12)
        .padding(.vertical, 10)
    }
}

public struct LessonView: ReduxView {
    public struct DataModel {
        let lesson: Lesson?
    }
    
    @SwiftUI.State var showAuthor: Bool = true
    @SwiftUI.State var useSpacer: Bool = false
    let authorSource: String?
    let lessonId: String
    public func map(_ state: AppState, dispatch: @escaping Dispatcher) -> DataModel {
        guard let lessonsSource = authorSource != nil ?
                state.lessonsState.fetchedAuthorLessons[authorSource!] :
                state.lessonsState.lessons else {
            return DataModel(lesson: nil)
        }
        return DataModel(lesson: lessonsSource[lessonId])
    }
    
    public func body(_ dataModel: DataModel) -> some View {
        ZStack(alignment: .bottomLeading) {
            if let lessong = dataModel.lesson {
                HStack(alignment: .top) {
                    if showAuthor {
                        ZStack(alignment: .topLeading) {
                            WebImageView(url: lessong.imageUrl?.absoluteString ?? "")
                                .scaledToFit()
                                .padding(.top, 2)
                                .padding(.trailing, -70)
                                .frame(width: 100)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.primary.opacity(0.05), Color.secondary.opacity(0.3)]), startPoint: .bottom, endPoint: .top)
                                )
                                .cornerRadius(5)
                                .clipped()
                                .shadow(color: Color.black.opacity(0.15),
                                        radius: 2, x: 0, y: 3)
                        }.fixedSize()
                    }
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: showAuthor ? 4 : 12) {
                            Text(lessong.name)
                                .font(.headline)
                                .foregroundColor(Color.primary)
                                .lineLimit(2)
                            if showAuthor {
                                Text("with \(lessong.teacherName)")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                            } else {
                                if useSpacer {
                                    Spacer()
                                }
                                RatingView(rating: .constant(lessong.rating), onColor: Color.blue.opacity(0.6))
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 3)
                            }
                        }
                        if !showAuthor && !useSpacer {
                            Spacer()
                            HStack(alignment: .center, spacing: 15) {
                                Text("\(lessong.stringPriceValue)\n\(lessong.stringPriceSymbol)")
                                    .foregroundColor(Color.primary)
                                    .font(.subheadline)
                                    .fontWeight(.regular)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 4)
                                Image(systemName: "chevron.right")
                                    .font(.title3)
                                    .accentColor(Color.primary.opacity(0.3))
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 3)
                            }
                        }
                    }.padding(.top, showAuthor ? 6 : 0)
                    .padding(.leading, showAuthor ? 6 : 0)
                }.padding(.top, showAuthor ? 8 : 0)
                .padding(.bottom, showAuthor ? 8 : 0)
                if showAuthor {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(dataModel.lesson?.stringPrice ?? "")
                            .font(.subheadline)
                            .foregroundColor(Color.primary)
                            .fontWeight(.bold)
                        RatingView(rating: .constant(lessong.rating))
                            .shadow(color: Color.black.opacity(0.15),
                                    radius: 2, x: 0, y: 3)
                    }.padding(.bottom, 15)
                    .padding(.leading, 106)
                    .padding(.leading, 6)
                }
            }  else {
                EmptyView()
            }
        }
    }
}

//struct LessonView_Previews: PreviewProvider {
//    static var previews: some View {
//        LessonView(authorSource: nil, lessonId: AppCoordinator.sampleStore.state.lessonsState.lessons.first!.value.id)
//            .environmentObject(AppCoordinator.sampleStore)
//    }
//}
