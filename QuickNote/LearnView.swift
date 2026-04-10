//
//  LearnView.swift
//  QuickNote
//
//  Created by Michael Fluharty on 4/10/26.
//

import SwiftUI

struct SourceFile: Identifiable {
    let id = UUID()
    let name: String
    let code: String
}

struct LearnView: View {
    @State private var selectedFile: SourceFile?

    private let sourceFiles: [SourceFile] = [
        SourceFile(name: "Note.swift", code: SourceCode.note),
        SourceFile(name: "QuickNoteApp.swift", code: SourceCode.app),
        SourceFile(name: "ContentView.swift", code: SourceCode.contentView),
        SourceFile(name: "NoteDetailView.swift", code: SourceCode.noteDetailView),
        SourceFile(name: "LearnView.swift", code: SourceCode.learnView),
        SourceFile(name: "ContactDeveloperView.swift", code: SourceCode.contactDeveloperView),
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
                    Text("For the full walkthrough, see Claude's Xcode 26 Swift Bible")
                        .font(.system(size: 18, weight: .light).italic())
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
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationTitle(file.name)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                ShareLink(item: file.code) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
    }
}

extension SourceFile: Hashable {
    static func == (lhs: SourceFile, rhs: SourceFile) -> Bool {
        lhs.name == rhs.name
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
