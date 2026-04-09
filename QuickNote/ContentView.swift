//
//  ContentView.swift
//  QuickNote
//
//  Created by Michael Fluharty on 4/6/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.dateCreated, order: .reverse) private var notes: [Note]

    var body: some View {
        NavigationSplitView {
            Group {
                if notes.isEmpty {
                    ContentUnavailableView(
                        "No Notes",
                        systemImage: "note.text",
                        description: Text("Press + to enter your first note")
                    )
                    .font(.system(size: 18))
                } else {
                    List {
                        ForEach(notes) { note in
                            NavigationLink {
                                NoteDetailView(note: note)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(quickNoteDateFormatter.string(from: note.dateCreated).uppercased())
                                        .font(.system(size: 20))
                                        .foregroundStyle(.secondary)
                                    Text(note.title.isEmpty ? "Untitled" : note.title)
                                        .font(.system(size: 18, weight: .bold))
                                        .lineLimit(1)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete(perform: deleteNotes)
                    }
                }
            }
            .navigationTitle("QuickNote")
            .navigationSplitViewColumnWidth(min: 280, ideal: 320)
#if os(iOS)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                        .font(.system(size: 18))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addNote) {
                        Label("Add Note", systemImage: "plus")
                    }
                    .font(.system(size: 18))
                }
            }
#else
            .toolbar {
                ToolbarItem {
                    Button(action: addNote) {
                        Label("Add Note", systemImage: "plus")
                    }
                }
            }
#endif
        } detail: {
            Text("Select a note")
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
        }
    }

    private func addNote() {
        withAnimation {
            let note = Note()
            modelContext.insert(note)
        }
    }

    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(notes[index])
            }
        }
    }
}

let quickNoteDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy MMM dd HHmmss"
    f.locale = Locale(identifier: "en_US_POSIX")
    return f
}()

#Preview {
    ContentView()
        .modelContainer(for: Note.self, inMemory: true)
}
