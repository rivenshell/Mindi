//
//  LoginView.swift
//  Mindi
//
//  Created by Riv Sal on 11/16/25.
//

import SwiftUI

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            // Background image
            
            Image("blue_calm")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 450)
                .clipped()
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 5)
                .padding(.horizontal, 20)
                .padding(.top, 20)


            VStack(spacing: 30) {
                Spacer()

                Spacer()

                // Mock Sign in with Apple button (for development)
                // TODO: Replace with real SignInWithAppleButton when you have paid Apple Developer account
                
                
                
                
                Button(action: {
                    handleMockSignIn()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "applelogo")
                            .font(.system(size: 20, weight: .medium))
                        Text("Sign in with Apple")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(colorScheme == .dark ? .white : .black)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)

                
                
                // Google Sign-In button
                Button(action: {
                    Task {
                        await handleGoogleSignIn()
                    }
                }) {
                    HStack(spacing: 8) {
                        Image("Google__G__logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text("Sign in with Google")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 0.01, green: 0.01, blue: 0.01))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .disabled(isLoading)

                // Error message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal, 40)
                }

                Spacer()
                    .frame(height: 60)

            }

        }
    }

    private func handleMockSignIn() {
        // Mock authentication for development
        // When you have a paid Apple Developer account, replace this with real Sign in with Apple
        print("Mock Sign in with Apple - Logging in...")

        // Simulate authentication
        isLoggedIn = true
    }

    private func handleGoogleSignIn() async {
        isLoading = true
        errorMessage = nil

        do {
            try await GoogleSignInManager.shared.signIn()
            // Successfully signed in
            isLoggedIn = true
        } catch {
            errorMessage = "Sign in failed: \(error.localizedDescription)"
            print("Google Sign-In error: \(error)")
        }

        isLoading = false
    }
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}
