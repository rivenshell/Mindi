//
//  JournalEntryDetailView.swift
//  Mindi
//
//  Created by Claude Code
//

import SwiftUI

struct JournalEntryDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var todoService: TodoService
    @State private var entry: Todo
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedBody: String

    init(entry: Todo, todoService: TodoService) {
        self.todoService = todoService
        _entry = State(initialValue: entry)
        _editedTitle = State(initialValue: entry.title)
        _editedBody = State(initialValue: entry.body ?? "")
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Date
                    Text(entry.createdAt, style: .date)
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.7, green: 0.68, blue: 0.65))

                    if isEditing {
                        // Edit Mode
                        VStack(alignment: .leading, spacing: 16) {
                            TextField("Title", text: $editedTitle)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(red: 0.9, green: 0.85, blue: 0.8))
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.7, green: 0.68, blue: 0.65).opacity(0.3), lineWidth: 1)
                                )

                            TextEditor(text: $editedBody)
                                .font(.body)
                                .foregroundStyle(Color(red: 0.9, green: 0.85, blue: 0.8))
                                .scrollContentBackground(.hidden)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.7, green: 0.68, blue: 0.65).opacity(0.3), lineWidth: 1)
                                )
                                .frame(minHeight: 300)
                        }
                    } else {
                        // View Mode
                        VStack(alignment: .leading, spacing: 16) {
                            Text(entry.title)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(red: 0.9, green: 0.85, blue: 0.8))

                            if let body = entry.body, !body.isEmpty {
                                Text(body)
                                    .font(.body)
                                    .foregroundStyle(Color(red: 0.85, green: 0.82, blue: 0.78))
                                    .lineSpacing(4)
                            } else {
                                Text("No content")
                                    .font(.body)
                                    .foregroundStyle(Color(red: 0.6, green: 0.58, blue: 0.55))
                                    .italic()
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Journal Entry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isEditing {
                    Button("Save") {
                        saveChanges()
                    }
                    .foregroundStyle(Color(red: 0.9, green: 0.85, blue: 0.8))
                } else {
                    Button("Edit") {
                        isEditing = true
                    }
                    .foregroundStyle(Color(red: 0.9, green: 0.85, blue: 0.8))
                }
            }

            if isEditing {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isEditing = false
                        editedTitle = entry.title
                        editedBody = entry.body ?? ""
                    }
                    .foregroundStyle(Color(red: 0.9, green: 0.85, blue: 0.8))
                }
            }
        }
    }

    private func saveChanges() {
        var updatedEntry = entry
        updatedEntry.title = editedTitle
        updatedEntry.body = editedBody.isEmpty ? nil : editedBody

        Task {
            await todoService.updateTodo(updatedEntry)
            await MainActor.run {
                entry = updatedEntry
                isEditing = false
            }
        }
    }
}
