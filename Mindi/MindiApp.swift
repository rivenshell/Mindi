//
//  MindiApp.swift
//  Mindi
//
//  Created by Riv Sal on 11/8/25.
//

import SwiftUI

@main
struct MindiApp: App {

    @AppStorage("onboarded") private var onboarded = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    var body: some Scene {
        WindowGroup {
            RootView(
                onboarded: $onboarded,
                isLoggedIn: $isLoggedIn
            )
            .preferredColorScheme(.dark)
        }
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
                    ContentView()
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
            // Show launch screen for 0.5 seconds before showing content
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isInitialized = true
            }
        }
    }
}
