//
//  QuickNoteWidgetExtension.swift
//  QuickNoteWidgetExtension
//
//  Created by Michael Fluharty on 4/10/26.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> NoteEntry {
        NoteEntry(date: .now, notes: [
            (title: "Sample Note", dateCreated: .now)
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (NoteEntry) -> Void) {
        completion(fetchEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NoteEntry>) -> Void) {
        let entry = fetchEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func fetchEntry() -> NoteEntry {
        do {
            let groupURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.com.ClaudeX26Bible.QuickNote"
            )!.appending(path: "default.store")
            let config = ModelConfiguration("QuickNote", schema: Schema([Note.self]), url: groupURL)
            let container = try ModelContainer(for: Note.self, configurations: config)
            let context = ModelContext(container)
            let descriptor = FetchDescriptor<Note>(sortBy: [SortDescriptor(\.dateCreated, order: .reverse)])
            let notes = try context.fetch(descriptor)
            let topNotes = notes.prefix(3).map {
                (title: $0.title.isEmpty ? "Untitled" : $0.title, dateCreated: $0.dateCreated)
            }
            return NoteEntry(date: .now, notes: Array(topNotes))
        } catch {
            return NoteEntry(date: .now, notes: [])
        }
    }
}

struct NoteEntry: TimelineEntry {
    let date: Date
    let notes: [(title: String, dateCreated: Date)]
}

struct QuickNoteWidgetEntryView: View {
    var entry: NoteEntry
    @Environment(\.widgetFamily) var family

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM dd HHmm"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    var body: some View {
        if entry.notes.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "note.text")
                    .font(.system(size: 24))
                    .foregroundStyle(.secondary)
                Text("No Notes")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }
        } else {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(entry.notes.enumerated()), id: \.offset) { _, note in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(note.title)
                            .font(.system(size: 16, weight: .semibold))
                            .lineLimit(1)
                        Text(dateFormatter.string(from: note.dateCreated).uppercased())
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    if family != .systemSmall {
                        Divider()
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(.vertical, 4)
        }
    }
}

struct QuickNoteWidgetExtension: Widget {
    let kind: String = "QuickNoteWidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            QuickNoteWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Recent Notes")
        .description("Shows your most recent notes.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    QuickNoteWidgetExtension()
} timeline: {
    NoteEntry(date: .now, notes: [(title: "My First Note", dateCreated: .now)])
}
