//
//  SourceCode.swift
//  QuickNote
//
//  Created by Michael Fluharty on 4/10/26.
//
//  Embedded source code for the Learn tab.
//  Each static property contains the source of a Swift file
//  as it shipped in v1.1. Pop the hood, see the engine.
//  For the full walkthrough, see Claude's Xcode 26 Swift Bible.
//

enum SourceCode {

    static let note = """
    import Foundation
    import SwiftData

    @Model
    final class Note {
        var title: String
        var dateCreated: Date
        var body: String
        var dateModified: Date

        init(title: String = "", dateCreated: Date = .now,
             body: String = "", dateModified: Date = .now) {
            self.title = title
            self.dateCreated = dateCreated
            self.body = body
            self.dateModified = dateModified
        }
    }
    """

    static let app = """
    import SwiftUI
    import SwiftData

    @main
    struct QuickNoteApp: App {
        var sharedModelContainer: ModelContainer = {
            let schema = Schema([Note.self])
            let config = ModelConfiguration(
                schema: schema, isStoredInMemoryOnly: false
            )
            do {
                return try ModelContainer(
                    for: schema, configurations: [config]
                )
            } catch {
                fatalError("Could not create ModelContainer: \\(error)")
            }
        }()

        var body: some Scene {
            WindowGroup {
                TabView {
                    ContentView()
                        .tabItem {
                            Label("Notes", systemImage: "note.text")
                        }
                    LearnView()
                        .tabItem {
                            Label("Under the Hood",
                                  systemImage: "wrench.and.screwdriver")
                        }
                }
            }
            .modelContainer(sharedModelContainer)
        }
    }
    """

    static let contentView = """
    import SwiftUI
    import SwiftData

    struct ContentView: View {
        @Environment(\\.modelContext) private var modelContext
        @Query(sort: \\Note.dateCreated, order: .reverse)
        private var notes: [Note]
        @State private var selectedNote: Note?

        var body: some View {
            NavigationSplitView {
                Group {
                    if notes.isEmpty {
                        ContentUnavailableView(
                            "No Notes",
                            systemImage: "note.text",
                            description: Text(
                                "Press + to enter your first note"
                            )
                        )
                        .font(.system(size: 18))
                    } else {
                        List(selection: $selectedNote) {
                            ForEach(notes) { note in
                                NavigationLink(value: note) {
                                    VStack(alignment: .leading,
                                           spacing: 4) {
                                        Text(quickNoteDateFormatter
                                            .string(from: note.dateCreated)
                                            .uppercased())
                                            .font(.system(size: 20))
                                            .foregroundStyle(.secondary)
                                        Text(note.title.isEmpty
                                             ? "Untitled" : note.title)
                                            .font(.system(size: 18,
                                                          weight: .bold))
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
                .navigationSplitViewColumnWidth(
                    min: 350, ideal: 380
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
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
            } detail: {
                if let selectedNote {
                    NoteDetailView(note: selectedNote)
                } else {
                    Text("Select a note")
                        .font(.system(size: 18))
                        .foregroundStyle(.secondary)
                }
            }
        }

        private func addNote() {
            withAnimation {
                let note = Note()
                modelContext.insert(note)
                selectedNote = note
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
        f.dateFormat = "yyyy MMM dd HHmm"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
    """

    static let noteDetailView = """
    import SwiftUI
    import SwiftData

    struct NoteDetailView: View {
        @Bindable var note: Note

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TextField("Title", text: $note.title)
                        .font(.system(size: 24, weight: .bold))
                        .onChange(of: note.title) {
                            note.dateModified = .now
                        }

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

                    TextEditor(text: $note.body)
                        .font(.system(size: 18))
                        .frame(minHeight: 200)
                        .scrollContentBackground(.hidden)
                        .onChange(of: note.body) {
                            note.dateModified = .now
                        }

                    Spacer()

                    Text("Modified: \\(quickNoteDateFormatter
                        .string(from: note.dateModified)
                        .uppercased())")
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
            text += "\\n\\(quickNoteDateFormatter
                .string(from: note.dateCreated).uppercased())"
            text += "\\n\\n\\(note.body)"
            text += "\\n\\nModified: \\(quickNoteDateFormatter
                .string(from: note.dateModified).uppercased())"
            return text
        }
    }
    """

    static let contactDeveloperView = """
    import SwiftUI

    struct ContactDeveloperView: View {
        @Environment(\\.dismiss) private var dismiss
        @Environment(\\.openURL) private var openURL
        @State private var feedbackText = ""
        @State private var showingMailFallback = false
        @State private var showingSentConfirmation = false

        private let developerEmail = "michael.fluharty@mac.com"
        private let appVersion: String = {
            let version = Bundle.main.infoDictionary?[
                "CFBundleShortVersionString"] as? String ?? "?"
            let build = Bundle.main.infoDictionary?[
                "CFBundleVersion"] as? String ?? "?"
            return "\\(version) (\\(build))"
        }()
        private var deviceInfo: String {
            let device = ProcessInfo.processInfo.hostName
            let os = ProcessInfo.processInfo
                .operatingSystemVersionString
            return "\\(device), \\(os)"
        }

        var body: some View {
            NavigationStack {
                Form {
                    Section {
                        Text("Got a suggestion, found a bug, "
                             + "or just want to say hi?")
                            .font(.system(size: 18))
                    }
                    Section("Your Feedback") {
                        TextEditor(text: $feedbackText)
                            .font(.system(size: 18))
                            .frame(minHeight: 150)
                    }
                    Section("Device Info") {
                        LabeledContent("App") {
                            Text("QuickNote by Claude "
                                 + "v\\(appVersion)")
                        }
                        LabeledContent("Device") {
                            Text(deviceInfo)
                        }
                    }
                    Section {
                        Button(action: sendFeedback) {
                            Label("Send Feedback",
                                  systemImage: "paperplane.fill")
                        }
                        .disabled(feedbackText.trimmingCharacters(
                            in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .navigationTitle("Contact Developer")
            }
        }

        private func sendFeedback() {
            // Composes mailto: URL and opens Mail
            let subject = "QuickNote by Claude Feedback"
            let body = feedbackText
                + "\\n\\n--- Device Info ---"
                + "\\nApp: QuickNote v\\(appVersion)"
                + "\\nDevice: \\(deviceInfo)"
            let encoded = body.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed) ?? ""
            let encodedSubject = subject.addingPercentEncoding(
                withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let url = URL(string:
                "mailto:\\(developerEmail)"
                + "?subject=\\(encodedSubject)"
                + "&body=\\(encoded)") {
                openURL(url)
            }
        }
    }
    """

    static let learnView = """
    import SwiftUI

    struct SourceFile: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let code: String

        static func == (lhs: SourceFile, rhs: SourceFile) -> Bool {
            lhs.name == rhs.name
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }
    }

    struct LearnView: View {
        @State private var selectedFile: SourceFile?

        private let sourceFiles: [SourceFile] = [
            SourceFile(name: "Note.swift",
                       code: SourceCode.note),
            SourceFile(name: "QuickNoteApp.swift",
                       code: SourceCode.app),
            SourceFile(name: "ContentView.swift",
                       code: SourceCode.contentView),
            SourceFile(name: "NoteDetailView.swift",
                       code: SourceCode.noteDetailView),
            SourceFile(name: "LearnView.swift",
                       code: SourceCode.learnView),
        ]

        var body: some View {
            NavigationSplitView {
                List(sourceFiles, selection: $selectedFile) { file in
                    NavigationLink(value: file) {
                        Label(file.name, systemImage: "swift")
                            .font(.system(size: 18))
                    }
                }
                .navigationTitle("Under the Hood")
            } detail: {
                if let selectedFile {
                    SourceCodeDetailView(file: selectedFile)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "wrench.and.screwdriver")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("Select a file to view its source code")
                            .font(.system(size: 18))
                            .foregroundStyle(.secondary)
                        Text("For the full walkthrough, see "
                             + "Claude's Xcode 26 Swift Bible")
                            .font(.system(size: 18, weight: .light)
                                .italic())
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }

    struct SourceCodeDetailView: View {
        let file: SourceFile

        var body: some View {
            ScrollView(.horizontal) {
                ScrollView(.vertical) {
                    Text(file.code)
                        .font(.system(size: 16, design: .monospaced))
                        .textSelection(.enabled)
                        .padding()
                        .frame(maxWidth: .infinity,
                               alignment: .leading)
                }
            }
            .navigationTitle(file.name)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    ShareLink(item: file.code) {
                        Label("Share",
                              systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
    }
    """
}
