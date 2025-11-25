//
//  Google.swift
//  Mindi
//
//  Created by Riv Sal on 11/25/25.
//

import Foundation
import SwiftUI
import GoogleSignIn
import Supabase

@MainActor
class GoogleSignInManager {
    static let shared = GoogleSignInManager()

    private init() {}

    func signIn() async throws {
        // Get the root view controller for presenting the sign-in UI
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw GoogleSignInError.noViewController
        }

        // Present Google Sign-In
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

        // Extract tokens
        guard let idToken = result.user.idToken?.tokenString else {
            throw GoogleSignInError.noIdToken
        }

        let accessToken = result.user.accessToken.tokenString

        // Sign in to Supabase with Google credentials
        try await supabase.auth.signInWithIdToken(
            credentials: OpenIDConnectCredentials(
                provider: .google,
                idToken: idToken,
                accessToken: accessToken
            )
        )
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
}

enum GoogleSignInError: LocalizedError {
    case noViewController
    case noIdToken

    var errorDescription: String? {
        switch self {
        case .noViewController:
            return "Could not find a view controller to present sign-in"
        case .noIdToken:
            return "No ID token found from Google Sign-In"
        }
    }
}
