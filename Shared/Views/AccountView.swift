//
//  AccountView.swift
//  Feedac Learn
//
//  Created by Marius Ilie on 13.09.2020.
//

import SwiftUI
import AuthenticationServices
import SDWebImageSwiftUI
import Feedac_CoreRedux
import Feedac_UIRedux

import AuthenticationServices

final class SignInWithApple: UIViewRepresentable {
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        return ASAuthorizationAppleIDButton()
    }
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
    }
}

public struct AccountView: ReduxView {
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject private var store: Store<AppState>
    @SwiftUI.State private var hasLoadedGifs: Bool = true
    
    public struct DataModel {
        let isLoggedIn: Bool
        let user: User?
    }
    
    public func map(_ state: AppState, dispatch: @escaping Dispatcher) -> DataModel {
        return DataModel(isLoggedIn: state.userState.isLoading, user: state.userState.currentUser)
    }
    
    private func showAppleLogin() {
      let request = ASAuthorizationAppleIDProvider().createRequest()
      request.requestedScopes = [.fullName, .email]
      let controller = ASAuthorizationController(authorizationRequests: [request])
    }
    
    public func body(_ dataModel: DataModel) -> some View {
        NavigationView {
            if dataModel.isLoggedIn {
                AccountView()
            } else {
                ZStack(alignment: .bottom) {
                    VStack(alignment: .center, spacing: 34) {
                        VStack(alignment: .center, spacing: 12) {
                            Text("You are not logged-in.")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("You're unable to access this page for the moment. Please use one of the following options.")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                        }.padding(.horizontal)
                        VStack(alignment: .center, spacing: 12) {
                            SignInWithApple()
                                .frame(height: 44)
                                .shadow(color: Color.white, radius: 1, x: 0, y: 0)
                            Text("or").font(.body)
                            Button(action: { }) {
                                Text("Enroll as a Teacher").font(.headline)
                            }
                        }
                        Spacer()
                    }.padding().padding(.horizontal, 8).layoutPriority(1)
                    ZStack {
                        AnimatedImage(url: URL(string: "https://feedac.com/loginloop2.gif"),
                                      isAnimating: $hasLoadedGifs).onSuccess(perform: { _ in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.23) {
                                hasLoadedGifs = false
                            }
                        }).resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal, 55)
                        .padding(.bottom, -32)
                        .layoutPriority(0)
                    }
                }
            }
        }
    }
}
