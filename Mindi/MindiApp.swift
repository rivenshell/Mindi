//
//  MindiApp.swift
//  Mindi
//
//  Created by Riv Sal on 11/8/25.
//

import SwiftUI
import GoogleSignIn

@main
struct MindiApp: App {

    @AppStorage("onboarded") private var onboarded = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    init() {
        configureGoogleSignIn()
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                onboarded: $onboarded,
                isLoggedIn: $isLoggedIn
            )
            .preferredColorScheme(.dark)
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }

    private func configureGoogleSignIn() {
        guard let path = Bundle.main.path(forResource: "Google_Sign-In_Credentials", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path),
              let clientID = config["CLIENT_ID"] as? String else {
            print("Error: Could not load Google Sign-In credentials")
            return
        }

        let configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = configuration
    }
}

struct RootView: View {
    @Binding var onboarded: Bool
    @Binding var isLoggedIn: Bool

    @State private var isInitialized = false

    var body: some View {
        Group {
            if isInitialized {
                if isLoggedIn {
                    // User is logged in, show main app
                    ContentView(isLoggedIn: $isLoggedIn)
                } else if !onboarded {
                    // First time user, show onboarding
                    OnboardingView(isOnboardingComplete: $onboarded)
                } else {
                    // Onboarded but not logged in, show login
                    LoginView(isLoggedIn: $isLoggedIn)
                }
            } else {
                // Show launch screen for 0.5 seconds
                ZStack {
                    Color.white
                        .ignoresSafeArea()

                    Image("Mindi_Launch")
//                        .resizable()
//                        .scaledToFill()
//                        .ignoresSafeArea()
                }
            }
        }
        .onAppear {
            // Transition from launch screen immediately for fast loading
            isInitialized = true
        }
    }
}
