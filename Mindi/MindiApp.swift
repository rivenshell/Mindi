//
//  MindiApp.swift
//  Mindi
//
//  Created by Riv Sal on 11/8/25.
//

import SwiftUI
import GoogleSignIn
import Supabase

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

    @State private var isSessionVerified = false

    var body: some View {
        Group {
            if isSessionVerified {
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
                // Show launch screen while the real session is verified
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
        .task {
            // isLoggedIn is cached in UserDefaults, but the real session lives in
            // the Keychain and can expire or never have existed (e.g. stale cache
            // from a previous install). Verify against the real session before
            // deciding what to render, so a stale "true" can't skip onboarding
            // or the login screen. Bound the check so a hung network call can't
            // freeze the launch screen forever.
            if isLoggedIn {
                let verified = await (try? withTimeout(seconds: 5) {
                    _ = try await supabase.auth.session
                }) != nil
                isLoggedIn = verified
            }
            isSessionVerified = true
        }
    }
}

enum TimeoutError: Error { case timedOut }

func withTimeout<T: Sendable>(seconds: TimeInterval, operation: @escaping @Sendable () async throws -> T) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask { try await operation() }
        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            throw TimeoutError.timedOut
        }
        let result = try await group.next()!
        group.cancelAll()
        return result
    }
}
