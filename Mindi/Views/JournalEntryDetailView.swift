//
//  JournalEntryDetailView.swift
//  Mindi
//
//  Created by Claude Code
//

import SwiftUI

struct JournalEntryDetailView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var journalService: JournalService
    @State private var entry: JournalEntry
    @State private var isEditing = false
    @State private var editedTitle: String
    @State private var editedContent: String

    init(entry: JournalEntry, journalService: JournalService) {
        self.journalService = journalService
        _entry = State(initialValue: entry)
        _editedTitle = State(initialValue: entry.title ?? "")
        _editedContent = State(initialValue: entry.content)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Date
                    Text(entry.entryDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.7, green: 0.68, blue: 0.65))

                    if isEditing {
                        // Edit Mode
                        VStack(alignment: .leading, spacing: 16) {
                            TextField("Title (optional)", text: $editedTitle)
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

                            TextEditor(text: $editedContent)
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
                            Text(entry.title ?? "Untitled")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(red: 0.9, green: 0.85, blue: 0.8))

                            Text(entry.content)
                                .font(.body)
                                .foregroundStyle(Color(red: 0.85, green: 0.82, blue: 0.78))
                                .lineSpacing(4)

                            // Tags
                            if let tags = entry.tags, !tags.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Tags")
                                        .font(.caption)
                                        .foregroundStyle(Color(red: 0.7, green: 0.68, blue: 0.65))

                                    FlowLayout(spacing: 6) {
                                        ForEach(tags) { tag in
                                            Text(tag.name)
                                                .font(.caption)
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 5)
                                                .background(
                                                    Capsule()
                                                        .fill(Color(hex: tag.color ?? "6E7963"))
                                                )
                                        }
                                    }
                                }
                                .padding(.top, 8)
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
                        editedTitle = entry.title ?? ""
                        editedContent = entry.content
                    }
                    .foregroundStyle(Color(red: 0.9, green: 0.85, blue: 0.8))
                }
            }
        }
    }

    private func saveChanges() {
        Task {
            await journalService.updateEntry(
                id: entry.id,
                title: editedTitle.isEmpty ? nil : editedTitle,
                content: editedContent.isEmpty ? nil : editedContent
            )

            // Refetch to get updated entry from server
            if let updatedEntry = journalService.entries.first(where: { $0.id == entry.id }) {
                await MainActor.run {
                    entry = updatedEntry
                    isEditing = false
                }
            }
        }
    }
}

// MARK: - Flow Layout for Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint]

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var positions: [CGPoint] = []
            var size: CGSize = .zero
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let subviewSize = subview.sizeThatFits(.unspecified)

                if currentX + subviewSize.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, subviewSize.height)
                currentX += subviewSize.width + spacing
                size.width = max(size.width, currentX)
            }

            size.height = currentY + lineHeight
            self.size = size
            self.positions = positions
        }
    }
}
