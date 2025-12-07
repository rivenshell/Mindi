//
//  ProfileView.swift
//  Mindi
//
//  Created by Riv Sal on 11/9/25.
//

import SwiftUI
import Supabase
import GoogleSignIn

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    @State private var userName: String = "User"
    @State private var userEmail: String = ""
    @State private var profileImageURL: URL?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Profile Picture
                        AsyncImage(url: profileImageURL) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .foregroundColor(.gray)
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                     

                        // Greeting
                        Text("Hello, \(userName)!")
                            .font(.system(size: 28, weight: .bold))

                        // Email
                        if !userEmail.isEmpty {
                            Text(userEmail)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 20)

                    Divider()
                        .padding(.horizontal, 40)

                    // Wellness Tracking Section
                    VStack(spacing: 12) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 50))
                            .foregroundStyle(.purple)

                        Text("Wellness Tracking")
                            .font(.system(size: 20, weight: .semibold))

                        Text("Track your daily wellness journey")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 20)

                    Spacer()

                    // Sign Out Button
                    Button(action: {
                        handleSignOut()
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                            Text("Sign Out")
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Profile")
            .onAppear {
                loadUserProfile()
            }
        }
    }

    private func loadUserProfile() {
        // Try to get user info from Google Sign-In
        if let user = GIDSignIn.sharedInstance.currentUser {
            userName = user.profile?.name ?? "User"
            userEmail = user.profile?.email ?? ""
            profileImageURL = user.profile?.imageURL(withDimension: 200)
        }

        // Alternatively, fetch from Supabase
        Task {
            do {
                let user = try await supabase.auth.session.user
                if userName == "User" {
                    // Use Supabase data if Google data not available
                    userName = user.userMetadata["full_name"]?.value as? String ?? "User"
                    userEmail = user.email ?? ""
                }
            } catch {
                print("Error fetching user from Supabase: \(error)")
            }
        }
    }

    private func handleSignOut() {
        Task {
            // Sign out from Google
            await GoogleSignInManager.shared.signOut()

            // Sign out from Supabase
            try? await supabase.auth.signOut()

            // Update logged in state
            await MainActor.run {
                isLoggedIn = false
            }
        }
    }
}

#Preview {
    ProfileView(isLoggedIn: .constant(true))
}
