//
//  ContentView.swift
//  QuickNote
//
//  Created by Michael Fluharty on 4/6/26.
//

import SwiftUI
import SwiftData
import WidgetKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.dateCreated, order: .reverse) private var notes: [Note]
    @State private var selectedNote: Note?
    @State private var showingContact = false

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
                    List(selection: $selectedNote) {
                        ForEach(notes) { note in
                            NavigationLink(value: note) {
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
            .navigationTitle("Notes")
            .navigationSplitViewColumnWidth(min: 350, ideal: 380)
#if os(iOS)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        EditButton()
                            .font(.system(size: 18))
                        Button(action: { showingContact = true }) {
                            Label("Contact", systemImage: "envelope")
                        }
                        .font(.system(size: 18))
                    }
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
            if let selectedNote {
                NoteDetailView(note: selectedNote)
            } else {
                Text("Select a note")
                    .font(.system(size: 18))
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $showingContact) {
            ContactDeveloperView()
        }
    }

    private func addNote() {
        withAnimation {
            let note = Note()
            modelContext.insert(note)
            selectedNote = note
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(notes[index])
            }
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

let quickNoteDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy MMM dd HHmm"
    f.locale = Locale(identifier: "en_US_POSIX")
    return f
}()

#Preview {
    ContentView()
        .modelContainer(for: Note.self, inMemory: true)
}
