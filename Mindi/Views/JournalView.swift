//
//  JournalView.swift
//  Mindi
//
//  Created by Riv Sal on 11/9/25.
//

import SwiftUI

struct JournalView: View {
    @Binding var isLoggedIn: Bool
    @StateObject private var journalService = JournalService()
    @State private var showAddEntry = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Spacer()
                        DayOfWeekTracker()
                            .foregroundStyle(Color(red: 0.9, green: 0.85, blue: 0.8))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                    // Journal List
                    if journalService.isLoading {
                        ProgressView()
                            .tint(Color(red: 0.9, green: 0.85, blue: 0.8))
                            .scaleEffect(1.5)
                            .frame(maxHeight: .infinity)
                    } else if journalService.entries.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "book.pages")
                                .font(.system(size: 50))
                                .foregroundStyle(Color(red: 0.7, green: 0.68, blue: 0.65))

                            Text("No entries yet")
                                .font(.title3)
                                .foregroundStyle(Color(red: 0.8, green: 0.78, blue: 0.75))

                            Text("Tap + to create your first journal entry")
                                .font(.caption)
                                .foregroundStyle(Color(red: 0.7, green: 0.68, blue: 0.65))
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(journalService.entries) { entry in
                                NavigationLink(destination: JournalEntryDetailView(entry: entry, journalService: journalService)) {
                                    JournalEntryRow(entry: entry)
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        Task {
                                            await journalService.deleteEntry(entry)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }

                // Floating Add Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showAddEntry = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundStyle(.black)
                                .frame(width: 60, height: 60)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 0.95, green: 0.9, blue: 0.85),
                                                    Color(red: 0.85, green: 0.82, blue: 0.78)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView(isLoggedIn: $isLoggedIn)) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color(red: 0.9, green: 0.85, blue: 0.8))
                    }
                }
            }
            .sheet(isPresented: $showAddEntry) {
                AddEntrySheet(journalService: journalService, isPresented: $showAddEntry)
            }
            .task {
                await journalService.fetchEntries()
            }
            .alert("Error", isPresented: .constant(journalService.errorMessage != nil)) {
                Button("OK") {
                    journalService.errorMessage = nil
                }
            } message: {
                Text(journalService.errorMessage ?? "")
            }
        }
    }
}

// MARK: - Journal Entry Row
struct JournalEntryRow: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title and Date
            HStack {
                Text(entry.title ?? "Untitled")
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.9, green: 0.85, blue: 0.8))
                    .lineLimit(1)

                Spacer()

                Text(entry.entryDate, style: .date)
                    .font(.caption)
                    .foregroundStyle(Color(red: 0.7, green: 0.68, blue: 0.65))
            }

            // Content Preview
            Text(entry.content)
                .font(.subheadline)
                .foregroundStyle(Color(red: 0.8, green: 0.78, blue: 0.75))
                .lineLimit(2)

            // Tags
            if let tags = entry.tags, !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(tags) { tag in
                            Text(tag.name)
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color(hex: tag.color ?? "6E7963"))
                                )
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.7, green: 0.68, blue: 0.65).opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Add Entry Sheet
struct AddEntrySheet: View {
    @ObservedObject var journalService: JournalService
    @Binding var isPresented: Bool
    @State private var entryTitle = ""
    @State private var entryContent = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 20) {
                    TextField("Entry title (optional)", text: $entryTitle)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .foregroundStyle(Color(red: 0.9, green: 0.85, blue: 0.8))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.7, green: 0.68, blue: 0.65).opacity(0.3), lineWidth: 1)
                        )

                    ZStack(alignment: .topLeading) {
                        if entryContent.isEmpty {
                            Text("Write your journal entry here...")
                                .font(.body)
                                .foregroundStyle(Color(red: 0.6, green: 0.58, blue: 0.55))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                        }

                        TextEditor(text: $entryContent)
                            .font(.body)
                            .foregroundStyle(Color(red: 0.9, green: 0.85, blue: 0.8))
                            .scrollContentBackground(.hidden)
                            .padding(4)
                    }
                    .frame(minHeight: 200)
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(red: 0.7, green: 0.68, blue: 0.65).opacity(0.3), lineWidth: 1)
                    )

                    Button(action: {
                        guard !entryContent.isEmpty else { return }
                        Task {
                            await journalService.createEntry(
                                title: entryTitle.isEmpty ? nil : entryTitle,
                                content: entryContent
                            )
                            isPresented = false
                        }
                    }) {
                        Text("Create Entry")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.95, green: 0.9, blue: 0.85),
                                        Color(red: 0.85, green: 0.82, blue: 0.78)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                    .disabled(entryContent.isEmpty)
                    .opacity(entryContent.isEmpty ? 0.5 : 1.0)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundStyle(Color(red: 0.9, green: 0.85, blue: 0.8))
                }
            }
        }
    }
}

#Preview {
    JournalView(isLoggedIn: .constant(true))
}
