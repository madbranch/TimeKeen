//
//  TimeKeenApp.swift
//  TimeKeen
//
//  Created by Adam Labranche on 2022-12-31.
//

import SwiftUI

@main
struct TimeKeenApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
