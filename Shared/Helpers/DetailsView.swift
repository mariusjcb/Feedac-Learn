//
//  DetailsView.swift
//  Feedac Learn
//
//  Created by Marius Ilie on 07.09.2020.
//

import SwiftUI
import Feedac_CoreRedux
import Feedac_UIRedux
import LocalAuthentication

public struct DetailsView: View {
    @SwiftUI.State var title: String
    @SwiftUI.State var content: String
    
    @SwiftUI.State var rightContent: String? = nil
    @SwiftUI.State var showRating: Bool = false
    @SwiftUI.State var rating: Int = 0
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .foregroundColor(Color.primary)
                        .font(.title)
                        .fontWeight(.medium)
                    if showRating {
                        RatingView(rating: $rating)
                            .padding(.bottom)
                    }
                }
                if let rightContent = rightContent {
                    Spacer()
                    Text(rightContent)
                        .foregroundColor(Color.primary)
                        .font(.title2)
                        .multilineTextAlignment(.trailing)
                        .padding(.top, 4)
                }
            }
            Text(content.prefix(245))
                .foregroundColor(Color.primary)
                .font(.body)
            if content.count > 245 {
                DisclosureGroup("[...] Read More.") {
                    Text(content.dropFirst(245))
                        .foregroundColor(Color.primary)
                        .font(.body)
                }.foregroundColor(Color.primary.opacity(0.5))
                .accentColor(Color.primary.opacity(0.5))
            }
        }
    }
}
