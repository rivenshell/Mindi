//
//  CalendarView.swift
//  Mindi
//
//  Created by Riv Sal on 11/9/25.
//

import SwiftUI

struct CalendarView: View {
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
                            Image(systemName: "checklist")
                                .font(.system(size: 50))
                                .foregroundStyle(Color(red: 0.7, green: 0.68, blue: 0.65))

                            Text("No todos yet")
                                .font(.title3)
                                .foregroundStyle(Color(red: 0.8, green: 0.78, blue: 0.75))

                            Text("Tap + to add your first todo")
                                .font(.caption)
                                .foregroundStyle(Color(red: 0.7, green: 0.68, blue: 0.65))
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(todoService.todos) { todo in
                                    TodoRow(todo: todo, todoService: todoService)
                                }
                            }
                            .padding(.horizontal)
                        }
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
            .navigationTitle("Calendar")
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

// MARK: - Todo Row
struct TodoRow: View {
    let todo: Todo
    @ObservedObject var todoService: TodoService

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: {
                Task {
                    await todoService.toggleTodoCompletion(todo)
                }
            }) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        todo.isCompleted ?
                            Color(red: 0.6, green: 0.9, blue: 0.6) :
                            Color(red: 0.7, green: 0.68, blue: 0.65)
                    )
            }

            // Todo Title
            Text(todo.title)
                .font(.body)
                .foregroundStyle(
                    todo.isCompleted ?
                        Color(red: 0.6, green: 0.58, blue: 0.55) :
                        Color(red: 0.9, green: 0.85, blue: 0.8)
                )
                .strikethrough(todo.isCompleted)

            Spacer()

            // Delete Button
            Button(action: {
                Task {
                    await todoService.deleteTodo(todo)
                }
            }) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(red: 0.9, green: 0.6, blue: 0.6))
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

// MARK: - Add Todo Sheet
struct AddTodoSheet: View {
    @ObservedObject var todoService: TodoService
    @Binding var isPresented: Bool
    @State private var todoTitle = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 24) {
                    TextField("Enter todo title", text: $todoTitle)
                        .font(.body)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .foregroundStyle(Color(red: 0.9, green: 0.85, blue: 0.8))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.7, green: 0.68, blue: 0.65).opacity(0.3), lineWidth: 1)
                        )

                    Button(action: {
                        guard !todoTitle.isEmpty else { return }
                        Task {
                            await todoService.createTodo(title: todoTitle)
                            isPresented = false
                        }
                    }) {
                        Text("Add Todo")
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
            .navigationTitle("New Todo")
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
    CalendarView()
}
