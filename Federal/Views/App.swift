//
//  FederalApp.swift
//  Federal
//
//  Created by シン on 2024/06/20.
//

import SwiftUI
import SwiftData

let sharedModelContainer: ModelContainer = {
    let schema = Schema([Speech.self, PressRelease.self, YouTubeInterview.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()

@main
struct FederalApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .modelContainer(sharedModelContainer)
    }
}
