//
//  Feedac_Learn_Widget.swift
//  Feedac Learn Widget
//
//  Created by Marius Ilie on 08.09.2020.
//

import WidgetKit
import SwiftUI
import Intents
import Feedac_CoreRedux
import Feedac_UIRedux

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}







struct Feedac_Learn_WidgetEntryView : ReduxView {
    @Environment(\.widgetFamily) private var family
    var entry: Provider.Entry
    
    struct DataModel {
        let bgImage: String
        let isLoading: Bool
        let lessons: [String]
    }
    func map(_ state: AppState, dispatch: @escaping Dispatcher) -> DataModel {
        let lessons: (String, String?, [String]) = { () -> (String, String?, [String]) in
            let lessons = state.lessonsState.lessons.values.sorted { $0.rating > $1.rating }
            return (lessons.last?.imageUrl?.absoluteString ?? "", nil, Array(lessons.map { $0.id }))
        }()
        return DataModel(bgImage: lessons.0,
                         isLoading: state.lessonsState.isLoading,
                         lessons: family != WidgetFamily.systemLarge ?
                            [lessons.2.first!] :
                            Array(lessons.2.prefix(2)))
    }

    func body(_ dataModel: DataModel) -> some View {
        LazyVStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .leading) {
                WebImageView(url: dataModel.bgImage)
                    .scaledToFill().overlay(Color.white.opacity(0.9))
                    .blur(radius: 20)
                VStack(alignment: .leading) {
                    if family == WidgetFamily.systemLarge {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .center) {
                                Image(systemName: "star.fill")
                                Text("Top Lessons").font(.subheadline)
                            }
                            Text("Open app for more lessons...")
                                .font(.footnote)
                                .foregroundColor(Color.black.opacity(0.5))
                        }
                    }
                    ForEach(dataModel.lessons, id: \.self) { id in
                        NavigationLink(destination: LessonDetailsView(authorSource: nil,
                                                                      lessonId: id)) {
                            LessonView(showAuthor: family != WidgetFamily.systemSmall,
                                       useSpacer: true,
                                       authorSource: nil,
                                       lessonId: id).background(Color.clear)
                        }
                    }.drawingGroup().background(Color.clear)
                }.padding(.horizontal).background(Color.clear)
            }
        }
    }
}





@main
struct Feedac_Learn_Widget: Widget {
    internal static let store = Store<AppState>(AppState(title: "PRODUCTION"),
                                                using: AppStateReducer,
                                                intercept: [AppLogger])
    
    let kind: String = "Feedac_Learn_Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            ReduxStoreUIContainer(Self.sampleStore) {
                Feedac_Learn_WidgetEntryView(entry: entry)
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

//#if DEBUG
extension Feedac_Learn_Widget {
    static var sampleStore = Store<AppState>(AppState(lessonsState: .sampleState,
                                                      userState: .sampleState),
                                             using: AppStateReducer,
                                             intercept: [AppLogger])
}
//#endif

struct Feedac_Learn_Widget_Previews: PreviewProvider {
    static var previews: some View {
        Feedac_Learn_WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
