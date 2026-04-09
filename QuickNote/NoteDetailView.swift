//
//  NoteDetailView.swift
//  QuickNote
//
//  Created by Michael Fluharty on 4/6/26.
//

import SwiftUI
import SwiftData

struct NoteDetailView: View {
    @Bindable var note: Note

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title
                TextField("Title", text: $note.title)
                    .font(.system(size: 24, weight: .bold))
                    .onChange(of: note.title) {
                        note.dateModified = .now
                    }

                // Date Created
                DatePicker(
                    "Date Created",
                    selection: $note.dateCreated,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .font(.system(size: 20))
                .foregroundStyle(.secondary)
                .onChange(of: note.dateCreated) {
                    note.dateModified = .now
                }

                // Body
                TextField("Note", text: $note.body, axis: .vertical)
                    .font(.system(size: 18))
                    .lineLimit(nil)
                    .onChange(of: note.body) {
                        note.dateModified = .now
                    }

                Spacer()

                // Date Modified
                Text("Modified: \(quickNoteDateFormatter.string(from: note.dateModified).uppercased())")
                    .font(.system(size: 18, weight: .light).italic())
                    .foregroundStyle(.tertiary)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                ShareLink(item: shareText)
            }
        }
    }

    private var shareText: String {
        var text = note.title
        text += "\n\(quickNoteDateFormatter.string(from: note.dateCreated).uppercased())"
        text += "\n\n\(note.body)"
        text += "\n\nModified: \(quickNoteDateFormatter.string(from: note.dateModified).uppercased())"
        return text
    }
}
