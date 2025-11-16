//
//  OnboardingView.swift
//  Mindi
//
//  Created by Riv Sal on 11/16/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var isOnboardingComplete: Bool

    var body: some View {
        ZStack {
            VStack {
                Spacer()

                // Card container
                VStack(spacing: 0) {
                    // Skip button
                    HStack {
                        Spacer()
                        Button("Skip") {
                            isOnboardingComplete = true
                        }
                        .foregroundColor(.secondary)
                        .padding()
                    }

                    // Carousel
                    TabView(selection: $currentPage) {
                        OnboardingCard(
                            imageName: "Hang_in_There_Cecilia",
//                            gradient: [Color.purple, Color.blue],
                            title: "Lets —",
                            page: 0
                        )
                        .tag(0)

                        OnboardingCard(
                            imageName: "Hang_in_There_Cecilia2",
//                            gradient: [Color.pink, Color.orange],
                            title: "Inhale",
                            page: 1
                        )
                        .tag(1)

                        OnboardingCard(
                            imageName: "blue_calm",
//                            gradient: [Color.blue, Color.cyan],
                            title: "Hold",
                            page: 2
                        )
                        .tag(2)
                        
                        OnboardingCard(imageName: "shadow_tech", title: "Exhale", page: 3
                        )
                            .tag(3)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                }
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: -5)
                )
                .padding(.horizontal, 20)

                // Terms and Services (only on first page) - Outside the card
                if currentPage == 0 {
                    VStack(spacing: 8) {
                        Text("By continuing you agree to Mindi's \(Text("conditions of use").foregroundColor(.blue)) and \(Text("privacy notice.").foregroundColor(.blue))")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)

                        Button("Need Help?") {
                            // Handle help action
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.blue)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                    .transition(.opacity)
                }

                // Get Started button (only on last page) - Outside the card
                if currentPage == 3 {
                    Button(action: {
                        isOnboardingComplete = true
                    }) {
                        Text("Jump in")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                    .transition(.opacity)
                }
            }
        }
    }
}

struct OnboardingCard: View {
    let imageName: String
    let title: String
    let page: Int

    var body: some View {
        VStack(spacing: 20) {
            // Full size image
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 450)
                .clipped()
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 5)
                .padding(.horizontal, 20)
                .padding(.top, 20)

            // Title
            Text(title)
                .font(.system(size: 64, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.top, 10)

            Spacer()
        }
        .padding(.bottom, 20)
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
}
