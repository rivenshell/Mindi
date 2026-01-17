//
//  JournalView.swift
//  Mindi
//
//  Created by Riv Sal on 11/9/25.
//

import SwiftUI

struct JournalView: View {
    @StateObject private var todoService = TodoService()
    @State private var newTodoTitle = ""
    @State private var showAddTodo = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Journaling Hub")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(red: 0.9, green: 0.85, blue: 0.8))

                        Image(systemName: "book.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color(red: 0.85, green: 0.82, blue: 0.78))
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 24)

                    // Todo List
                    if todoService.isLoading {
                        ProgressView()
                            .tint(Color(red: 0.9, green: 0.85, blue: 0.8))
                            .scaleEffect(1.5)
                            .frame(maxHeight: .infinity)
                    } else if todoService.todos.isEmpty {
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
                            ForEach(todoService.todos) { todo in
                                NavigationLink(destination: JournalEntryDetailView(entry: todo, todoService: todoService)) {
                                    JournalEntryRow(entry: todo)
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        Task {
                                            await todoService.deleteTodo(todo)
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
                            showAddTodo = true
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
            .sheet(isPresented: $showAddTodo) {
                AddTodoSheet(todoService: todoService, isPresented: $showAddTodo)
            }
            .task {
                await todoService.fetchTodos()
            }
            .alert("Error", isPresented: .constant(todoService.errorMessage != nil)) {
                Button("OK") {
                    todoService.errorMessage = nil
                }
            } message: {
                Text(todoService.errorMessage ?? "")
            }
        }
    }
}

// MARK: - Journal Entry Row
struct JournalEntryRow: View {
    let entry: Todo

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title and Date
            HStack {
                Text(entry.title)
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.9, green: 0.85, blue: 0.8))
                    .lineLimit(1)

                Spacer()

                Text(entry.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(Color(red: 0.7, green: 0.68, blue: 0.65))
            }

            // Body Preview
            if let body = entry.body, !body.isEmpty {
                Text(body)
                    .font(.subheadline)
                    .foregroundStyle(Color(red: 0.8, green: 0.78, blue: 0.75))
                    .lineLimit(2)
            } else {
                Text("No content")
                    .font(.subheadline)
                    .foregroundStyle(Color(red: 0.6, green: 0.58, blue: 0.55))
                    .italic()
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
struct AddTodoSheet: View {
    @ObservedObject var todoService: TodoService
    @Binding var isPresented: Bool
    @State private var todoTitle = ""
    @State private var todoBody = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 20) {
                    TextField("Entry title", text: $todoTitle)
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
                        if todoBody.isEmpty {
                            Text("Write your journal entry here...")
                                .font(.body)
                                .foregroundStyle(Color(red: 0.6, green: 0.58, blue: 0.55))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                        }

                        TextEditor(text: $todoBody)
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
                        guard !todoTitle.isEmpty else { return }
                        Task {
                            await todoService.createTodo(title: todoTitle, body: todoBody.isEmpty ? nil : todoBody)
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
                    .disabled(todoTitle.isEmpty)
                    .opacity(todoTitle.isEmpty ? 0.5 : 1.0)

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
    JournalView()
}
