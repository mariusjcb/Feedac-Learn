//
//  ReadMoreHomePageBanner.swift
//  Feedac Learn
//
//  Created by Marius Ilie on 05.09.2020.
//

import SwiftUI
import SDWebImageSwiftUI

struct ReadMoreHomePageBanner: View {
    var body: some View {
        ZStack {
            VStack {
                VStack(alignment: .center, spacing: 8) {
                    Text("They are the best!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Search for more teachers using the search button below!")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                }.padding(.horizontal)
                .padding(.top, 20)
                .zIndex(1)
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Search now")
                }.padding(.vertical, 8)
                .padding(.horizontal)
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.top)
                .zIndex(2)
                WebImage(url: URL(string: "https://feedac.com/wwdcanimated2.gif")!,
                         isAnimating: .constant(true))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(Color.black)
                    .padding(.top, 20)
            }.background(
                LinearGradient(gradient: Gradient(colors: [Color.primary.opacity(0), Color.primary.opacity(0), Color.secondary.opacity(0.15)]), startPoint: .bottom, endPoint: .top)
            )
        }.background(Color.black)
        .clipped().cornerRadius(10)
        .padding()
    }
}

struct ReadMoreHomePageBanner_Previews: PreviewProvider {
    static var previews: some View {
        ReadMoreHomePageBanner()
    }
}
