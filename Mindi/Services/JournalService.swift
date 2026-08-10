//
//  JournalService.swift
//  Mindi
//
//  Service for managing journal entries via Supabase
//

import Foundation
import Combine
import Supabase

class JournalService: ObservableObject {
    @Published var entries: [JournalEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let table = "journal_entries"

    // MARK: - Fetch Journal Entries

    func fetchEntries() async {
        await MainActor.run { isLoading = true }

        do {
            _ = try await supabase.auth.session
        } catch {
            await MainActor.run {
                self.errorMessage = "Please sign in to access your journal entries"
                self.isLoading = false
            }
            print("User not authenticated - cannot fetch journal entries")
            return
        }

        do {
            let fetchedEntries: [JournalEntry] = try await supabase
                .from(table)
                .select()
                .order("entry_date", ascending: false)
                .execute()
                .value

            await MainActor.run {
                self.entries = fetchedEntries
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to fetch journal entries: \(error.localizedDescription)"
                self.isLoading = false
            }
            print("Error fetching journal entries: \(error)")
        }
    }

    // MARK: - Create Journal Entry

    func createEntry(title: String?, content: String) async {
        do {
            let userId = try await supabase.auth.session.user.id

            let payload = NewJournalEntry(
                userId: userId,
                title: title,
                content: content,
                entryDate: PostgresDateParser.dateOnlyString(from: Date())
            )

            let newEntry: JournalEntry = try await supabase
                .from(table)
                .insert(payload)
                .select()
                .single()
                .execute()
                .value

            await MainActor.run {
                self.entries.insert(newEntry, at: 0)
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to create journal entry: \(error.localizedDescription)"
            }
            print("Error creating journal entry: \(error)")
        }
    }

    // MARK: - Update Journal Entry

    func updateEntry(id: UUID, title: String?, content: String?) async {
        do {
            let payload = JournalEntryUpdate(title: title, content: content)

            let updatedEntry: JournalEntry = try await supabase
                .from(table)
                .update(payload)
                .eq("id", value: id.uuidString)
                .select()
                .single()
                .execute()
                .value

            await MainActor.run {
                if let index = self.entries.firstIndex(where: { $0.id == id }) {
                    self.entries[index] = updatedEntry
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to update journal entry: \(error.localizedDescription)"
            }
            print("Error updating journal entry: \(error)")
        }
    }

    // MARK: - Delete Journal Entry

    func deleteEntry(_ entry: JournalEntry) async {
        do {
            try await supabase
                .from(table)
                .delete()
                .eq("id", value: entry.id.uuidString)
                .execute()

            await MainActor.run {
                self.entries.removeAll { $0.id == entry.id }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to delete journal entry: \(error.localizedDescription)"
            }
            print("Error deleting journal entry: \(error)")
        }
    }
}
