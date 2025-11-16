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

    var body: some View {
        ZStack {
            // Background image
            Image("WelcomeScreen")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 40) {
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
}

#Preview {
    LoginView(isLoggedIn: .constant(false))
}
