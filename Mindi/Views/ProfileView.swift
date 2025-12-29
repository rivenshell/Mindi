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

    // Data & Privacy Settings
    @AppStorage("journalCloudSyncEnabled") private var journalCloudSyncEnabled = true
    @AppStorage("journalPrivateMode") private var journalPrivateMode = false
    @AppStorage("journalEncryptionEnabled") private var journalEncryptionEnabled = false
    @AppStorage("autoBackupEnabled") private var autoBackupEnabled = true

    var body: some View {
        NavigationView {
            Form {
                // Profile Section
                Section {
                    HStack(spacing: 16) {
                        AsyncImage(url: profileImageURL) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .foregroundColor(.gray)
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(userName)
                                .font(.system(size: 20, weight: .semibold))

                            if !userEmail.isEmpty {
                                Text(userEmail)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Data & Privacy Section
                Section {
                    Toggle(isOn: $journalCloudSyncEnabled) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Cloud Sync")
                                .font(.system(size: 16))
                            Text("Sync journals across devices via Supabase")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                    .onChange(of: journalCloudSyncEnabled) { oldValue, newValue in
                        updateCloudSyncPreference(enabled: newValue)
                    }

                    Toggle(isOn: $journalPrivateMode) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Private Mode")
                                .font(.system(size: 16))
                            Text("Keep journals local only, don't sync to cloud")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }

                    Toggle(isOn: $journalEncryptionEnabled) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("End-to-End Encryption")
                                .font(.system(size: 16))
                            Text("Encrypt journal data before uploading")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }

                    Toggle(isOn: $autoBackupEnabled) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Auto Backup")
                                .font(.system(size: 16))
                            Text("Automatically backup journals to Supabase")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Data & Privacy")
                } footer: {
                    Text("Control how your journal data is stored and synced with Supabase backend.")
                }

                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }

                // Sign Out Section
                Section {
                    Button(action: {
                        handleSignOut()
                    }) {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                                .font(.system(size: 17, weight: .semibold))
                            Spacer()
                        }
                        .foregroundColor(.red)
                    }
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

    private func updateCloudSyncPreference(enabled: Bool) {
        Task {
            do {
                // Update user preferences in Supabase
                let user = try await supabase.auth.session.user

                // You can store this preference in a user_preferences table
                // or in the user metadata
                print("Cloud sync preference updated: \(enabled)")

                // If disabled, you might want to clear local sync state
                if !enabled {
                    print("Cloud sync disabled - journals will remain local only")
                }
            } catch {
                print("Error updating cloud sync preference: \(error)")
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
