//
//  ReviewRow.swift
//  Feedac Learn (iOS)
//
//  Created by Marius Ilie on 05/09/2020.
//

import SwiftUI
import Combine
import Feedac_CoreRedux
import Feedac_UIRedux

public struct ReviewRow: ReduxView {
    public struct DataModel {
        let review: Review?
    }
    
    let lessonSource: String?
    let reviewId: String
    
    public func map(_ state: AppState, dispatch: @escaping Dispatcher) -> DataModel {
        guard let lessonSource = lessonSource,
              let source = state.lessonsState.fetchedLessonReviews[lessonSource] else {
            return DataModel(review: nil)
        }
        return DataModel(review: source[reviewId])
    }
    
    public func body(_ dataModel: DataModel) -> some View {
        ZStack(alignment: .bottomLeading) {
            if let review = dataModel.review {
                DisclosureGroup (content: {
                    Text(review.message.dropFirst(100))
                        .foregroundColor(Color.primary.opacity(0.5))
                        .font(.body)
                }, label: {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .center, spacing: 20) {
                            WebImageView(url: review.imageUrl?.absoluteString ?? "")
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.primary.opacity(0.05), Color.secondary.opacity(0.3)]), startPoint: .bottom, endPoint: .top)
                                )
                                .clipShape(Circle())
                                .shadow(color: Color.primary.opacity(0.15), radius: 2, x: 0, y: 3)
                            VStack(alignment: .leading, spacing: 8) {
                                Text(review.authorName)
                                    .font(.headline)
                                    .foregroundColor(Color.primary)
                                    .lineLimit(2)
                                RatingView(rating: .constant(review.rating), onColor: Color.blue.opacity(0.6))
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 3)
                            }
                        }
                        Text(review.message.prefix(100))
                            .foregroundColor(Color.primary.opacity(0.5))
                            .font(.body)
                    }
                }).foregroundColor(Color.primary.opacity(0.5))
                .accentColor(Color.primary.opacity(0.5))
                .padding(.horizontal, 8)
            } else {
                EmptyView()
            }
        }
    }
}
