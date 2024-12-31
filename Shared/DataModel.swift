import SwiftUI
import SwiftData

actor DataModel {
    static let shared = DataModel()
    private init() {}
    
    nonisolated lazy var modelContainer: ModelContainer = {
    var inMemory = false
    
#if DEBUG
    if CommandLine.arguments.contains("enable-testing") {
        inMemory = true
        if let userDefaults = SharedData.userDefaults  {
            SharedData.Keys.allCases.forEach { userDefaults.removeObject(forKey: $0.rawValue)}
        }
    }
#endif
    
    do {
        return try ModelContainer(for: TimeEntry.self, BreakEntry.self, configurations: ModelConfiguration(isStoredInMemoryOnly: inMemory))
    } catch {
        fatalError("Failed to configure SwiftData container.")
    }
}()
}
