//
//  HomeView.swift
//  Feedac Learn (iOS)
//
//  Created by Marius Ilie on 05/09/2020.
//

import SwiftUI
import Feedac_CoreRedux

struct HomeView: View {
    var body: some View {
        NavigationView {
            LessonViewList()
                .navigationTitle("Feedac Learn")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environmentObject(AppCoordinator.sampleStore)
    }
}
