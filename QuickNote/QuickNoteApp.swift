//
//  QuickNoteApp.swift
//  QuickNote
//
//  Created by Michael Fluharty on 4/6/26.
//

import SwiftUI
import SwiftData

@main
struct QuickNoteApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Note.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
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
                        Label("Under the Hood", systemImage: "wrench.and.screwdriver")
                    }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
