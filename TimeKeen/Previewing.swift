import Foundation
import SwiftData

class Previewing {
    static var modelContainer: ModelContainer {
        try! ModelContainer(for: TimeEntry.self, BreakEntry.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }
    
    static var someTimeEntry: TimeEntry {
        timeEntry(from: (5, 30), to: (7, 0), on: 5)
    }
    
    static var someTimeEntries: [TimeEntry] {
        [
            timeEntry(from: (5, 30), to: (7, 0), on: 5),
            timeEntry(from: (9, 0), to: (12, 15), on: 5),
            timeEntry(from: (5, 30), to: (7, 0), on: 6),
        ]
    }
    
    static var sameDayTimeEntries: [TimeEntry] {
        [
            timeEntry(from: (5, 30), to: (7, 0), on: 5),
            timeEntry(from: (9, 0), to: (12, 15), on: 5),
            timeEntry(from: (5, 30), to: (7, 0), on: 5),
        ]
    }
    
    private static func timeEntry(from start: (Int, Int), to end: (Int, Int), on day: Int) -> TimeEntry {
        let calendar = Calendar.current
        let from = calendar.date(from: DateComponents(year: 2024, month: 9, day: day, hour: start.0, minute: start.1)) ?? Date.now
        let to = calendar.date(from: DateComponents(year: 2024, month: 9, day: day, hour: end.0, minute: end.1)) ?? Date.now
        return TimeEntry(from: from, to: to, notes: "Some notes...")
    }
}
