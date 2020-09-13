//
//  ContentView.swift
//  Feedac Learn App Clips
//
//  Created by Marius Ilie on 07.09.2020.
//

import SwiftUI
//import StoreKit
import AppClip
import CoreLocation

struct ContentView: View {
    @State private var finishedPayment: Bool = false
    
    var body: some View {
        NavigationView {
            Button(action: { finishedPayment.toggle() }) { Text("Hello, world!") }
                .padding()
        }
//        .appStoreOverlay(isPresented: $finishedPayment) {
//            SKOverlay.AppClipConfiguration(position: .bottom)
//        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleUserActivity)
    }
    
    func handleUserActivity(_ userActivity: NSUserActivity) {
        guard
            let incomingURL = userActivity.webpageURL,
            let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems
        else {
            return
        }
        
        if let lessonId = queryItems.first(where: { $0.name == "lessonId" })?.value {
            print(lessonId)
        }
        
//        guard
//            let payload = userActivity.appClipActivationPayload,
//            let latitudeValue = queryItems.first(where: { $0.name == "latitude" })?.value,
//            let longitudeValue = queryItems.first(where: { $0.name == "longitude" })?.value,
//            let latitude = Double(latitudeValue),
//            let longitude = Double(longitudeValue)
//        else {
//            return
//        }
//        
//        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        let region = CLCircularRegion(center: center, radius: 100, identifier: "location")
//        
//        payload.confirmAcquired(in: region) { inRegion, error in
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//            DispatchQueue.main.async {
//                print("DONE!")
//            }
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
