//
//  TodoService.swift
//  Mindi
//
//  Created by Claude Code
//

import Foundation
import Combine
import Supabase

class TodoService: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Fetch Todos
    func fetchTodos() async {
        await MainActor.run { isLoading = true }

        do {
            let response: [Todo] = try await supabase
                .from("todos")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value

            await MainActor.run {
                self.todos = response
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to fetch todos: \(error.localizedDescription)"
                self.isLoading = false
            }
            print("Error fetching todos: \(error)")
        }
    }

    // MARK: - Create Todo
    func createTodo(title: String, body: String? = nil) async {
        let newTodo = Todo(
            id: UUID(),
            title: title,
            body: body,
            isCompleted: false,
            createdAt: Date(),
            userId: nil
        )

        do {
            let response: Todo = try await supabase
                .from("todos")
                .insert(newTodo)
                .select()
                .single()
                .execute()
                .value

            await MainActor.run {
                self.todos.insert(response, at: 0)
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to create todo: \(error.localizedDescription)"
            }
            print("Error creating todo: \(error)")
        }
    }

    // MARK: - Update Todo
    func updateTodo(_ todo: Todo) async {
        do {
            let response: Todo = try await supabase
                .from("todos")
                .update(todo)
                .eq("id", value: todo.id.uuidString)
                .select()
                .single()
                .execute()
                .value

            await MainActor.run {
                if let index = self.todos.firstIndex(where: { $0.id == todo.id }) {
                    self.todos[index] = response
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to update todo: \(error.localizedDescription)"
            }
            print("Error updating todo: \(error)")
        }
    }

    // MARK: - Delete Todo
    func deleteTodo(_ todo: Todo) async {
        do {
            try await supabase
                .from("todos")
                .delete()
                .eq("id", value: todo.id.uuidString)
                .execute()

            await MainActor.run {
                self.todos.removeAll { $0.id == todo.id }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to delete todo: \(error.localizedDescription)"
            }
            print("Error deleting todo: \(error)")
        }
    }

    // MARK: - Toggle Todo Completion
    func toggleTodoCompletion(_ todo: Todo) async {
        var updatedTodo = todo
        updatedTodo.isCompleted.toggle()

        do {
            let response: Todo = try await supabase
                .from("todos")
                .update(updatedTodo)
                .eq("id", value: todo.id.uuidString)
                .select()
                .single()
                .execute()
                .value

            await MainActor.run {
                if let index = self.todos.firstIndex(where: { $0.id == todo.id }) {
                    self.todos[index] = response
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to update todo: \(error.localizedDescription)"
            }
            print("Error updating todo: \(error)")
        }
    }
}
