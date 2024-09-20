import Foundation
import SwiftData

class Previewing {
    static var modelContainer: ModelContainer {
        try! ModelContainer(for: TimeEntry.self, BreakEntry.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }
    
    static var someTimeEntry: TimeEntry {
        timeEntry(on: (9, 5), from: (5, 30), to: (7, 0))
    }
    
    static var someTimeEntries: [TimeEntry] {
        [
            // Pay Period 1
            // Aug 5 2024 to Aug 11
            timeEntry(on: (8, 5), from: (5, 30), to: (6, 0)),
            timeEntry(on: (8, 5), from: (6, 15), to: (8, 30)),
            timeEntry(on: (8, 5), from: (10, 0), to: (12, 0)),
            timeEntry(on: (8, 5), from: (13, 30), to: (14, 45)),
            timeEntry(on: (8, 6), from: (5, 30), to: (8, 15)),
            timeEntry(on: (8, 6), from: (10, 0), to: (12, 15)),
            timeEntry(on: (8, 6), from: (13, 15), to: (19, 0)),
            timeEntry(on: (8, 7), from: (5, 0), to: (7, 45)),
            timeEntry(on: (8, 7), from: (8, 0), to: (8, 30)),
            timeEntry(on: (8, 7), from: (10, 0), to: (11, 45)),
            timeEntry(on: (8, 7), from: (13, 0), to: (16, 0)),
            timeEntry(on: (8, 8), from: (5, 30), to: (8, 30)),
            timeEntry(on: (8, 8), from: (9, 30), to: (12, 30)),
            timeEntry(on: (8, 8), from: (13, 30), to: (17, 0)),
            timeEntry(on: (8, 9), from: (5, 30), to: (8, 15)),
            timeEntry(on: (8, 9), from: (10, 0), to: (12, 0)),
            timeEntry(on: (8, 9), from: (13, 0), to: (14, 0)),
            // Pay Period 2
            // Aug 12 to Aug 18
            timeEntry(on: (8, 12), from: (5, 30), to: (6, 15)),
            timeEntry(on: (8, 12), from: (6, 45), to: (8, 15)),
            timeEntry(on: (8, 12), from: (9, 30), to: (12, 0)),
            timeEntry(on: (8, 12), from: (13, 0), to: (16, 45)),
            timeEntry(on: (8, 13), from: (5, 0), to: (7, 45)),
            timeEntry(on: (8, 13), from: (9, 0), to: (12, 15)),
            timeEntry(on: (8, 13), from: (13, 15), to: (17, 15)),
            timeEntry(on: (8, 14), from: (6, 45), to: (11, 30)),
            timeEntry(on: (8, 14), from: (12, 45), to: (17, 0)),
            timeEntry(on: (8, 15), from: (5, 30), to: (6, 45)),
            timeEntry(on: (8, 15), from: (10, 45), to: (12, 30)),
            timeEntry(on: (8, 15), from: (13, 30), to: (15, 45)),
            timeEntry(on: (8, 15), from: (17, 45), to: (18, 30)),
            timeEntry(on: (8, 16), from: (5, 30), to: (7, 30)),
            timeEntry(on: (8, 16), from: (9, 15), to: (12, 0)),
            timeEntry(on: (8, 16), from: (13, 45), to: (15, 30)),
            // Pay Period 3
            // Aug 19 to Aug 25
            timeEntry(on: (8, 19), from: (6, 45), to: (7, 30)),
            timeEntry(on: (8, 19), from: (7, 45), to: (8, 30)),
            timeEntry(on: (8, 19), from: (9, 30), to: (11, 30)),
            timeEntry(on: (8, 19), from: (13, 0), to: (15, 30)),
            timeEntry(on: (8, 19), from: (16, 15), to: (16, 45)),
            timeEntry(on: (8, 20), from: (5, 30), to: (7, 45)),
            timeEntry(on: (8, 20), from: (9, 15), to: (12, 0)),
            timeEntry(on: (8, 20), from: (13, 15), to: (16, 45)),
            timeEntry(on: (8, 21), from: (5, 30), to: (8, 0)),
            timeEntry(on: (8, 21), from: (9, 15), to: (12, 0)),
            timeEntry(on: (8, 21), from: (13, 15), to: (17, 30)),
            timeEntry(on: (8, 22), from: (6, 15), to: (12, 0)),
            timeEntry(on: (8, 22), from: (13, 0), to: (16, 45)),
            timeEntry(on: (8, 23), from: (5, 0), to: (5, 15)),
            timeEntry(on: (8, 23), from: (5, 45), to: (8, 0)),
            timeEntry(on: (8, 23), from: (9, 15), to: (11, 0)),
            timeEntry(on: (8, 23), from: (12, 15), to: (14, 45), breaks: [(12, 45, 13, 30)]),
            // Pay Period 4
            // Aug 26 to Sep 1
            timeEntry(on: (8, 26), from: (5, 30), to: (8, 0)),
            timeEntry(on: (8, 26), from: (9, 15), to: (12, 0)),
            timeEntry(on: (8, 26), from: (13, 15), to: (17, 30)),
            timeEntry(on: (8, 27), from: (7, 30), to: (7, 45)),
            timeEntry(on: (8, 27), from: (9, 0), to: (12, 0)),
            timeEntry(on: (8, 27), from: (13, 15), to: (17, 0)),
            timeEntry(on: (8, 28), from: (5, 30), to: (8, 0)),
            timeEntry(on: (8, 28), from: (9, 0), to: (12, 15)),
            timeEntry(on: (8, 28), from: (13, 30), to: (17, 30)),
            timeEntry(on: (8, 29), from: (5, 30), to: (7, 15)),
            timeEntry(on: (8, 29), from: (9, 15), to: (11, 30)),
            timeEntry(on: (8, 29), from: (13, 0), to: (16, 45)),
            timeEntry(on: (8, 30), from: (5, 45), to: (6, 45)),
            timeEntry(on: (8, 30), from: (7, 0), to: (8, 45)),
            timeEntry(on: (8, 30), from: (9, 45), to: (12, 0)),
            timeEntry(on: (8, 30), from: (13, 15), to: (14, 15)),
            // Pay Period 5
            // Sep 2 to Sep 8
            timeEntry(on: (9, 3), from: (5, 30), to: (7, 45)),
            timeEntry(on: (9, 3), from: (9, 0), to: (12, 15)),
            timeEntry(on: (9, 3), from: (13, 15), to: (17, 15)),
            timeEntry(on: (9, 4), from: (5, 30), to: (7, 30)),
            timeEntry(on: (9, 4), from: (9, 15), to: (12, 0)),
            timeEntry(on: (9, 4), from: (13, 30), to: (18, 0)),
            timeEntry(on: (9, 5), from: (5, 30), to: (7, 15)),
            timeEntry(on: (9, 5), from: (8, 45), to: (12, 15)),
            timeEntry(on: (9, 5), from: (13, 15), to: (14, 45)),
            timeEntry(on: (9, 5), from: (15, 15), to: (16, 0)),
            timeEntry(on: (9, 6), from: (5, 30), to: (7, 0)),
            timeEntry(on: (9, 6), from: (9, 0), to: (12, 0)),
            timeEntry(on: (9, 6), from: (13, 0), to: (14, 15)),
            // Pay Period 6
            // Sep 9 to Sep 15
            timeEntry(on: (9, 9), from: (9, 0), to: (12, 0)),
            timeEntry(on: (9, 9), from: (12, 45), to: (17, 15)),
            timeEntry(on: (9, 10), from: (5, 30), to: (7, 30)),
            timeEntry(on: (9, 10), from: (9, 0), to: (12, 0)),
            timeEntry(on: (9, 10), from: (12, 45), to: (17, 15)),
        ]
    }
    
    static var sameDayTimeEntries: [TimeEntry] {
        [
            timeEntry(on: (8, 5), from: (5, 30), to: (6, 0)),
            timeEntry(on: (8, 5), from: (6, 15), to: (8, 30)),
            timeEntry(on: (8, 5), from: (10, 0), to: (12, 0)),
            timeEntry(on: (8, 5), from: (13, 30), to: (14, 45)),
        ]
    }
    
    private static func timeEntry(on date: (Int, Int), from start: (Int, Int), to end: (Int, Int), notes: String = "", breaks: [(Int, Int, Int, Int)] = [(Int, Int, Int, Int)]()) -> TimeEntry {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 2024, month: date.0, day: date.1, hour: start.0, minute: start.1)
        let startDate = calendar.date(from: startComponents)!
        let endComponents = DateComponents(year: 2024, month: date.0, day: date.1, hour: end.0, minute: end.1)
        let endDate = calendar.date(from: endComponents)!
        let timeEntry = TimeEntry(from: startDate, to: endDate, notes: notes)
        timeEntry.breaks.append(contentsOf: breaks.map { breakEntry(startDate, $0) })
        return timeEntry
    }
    
    private static func breakEntry(_ date: Date, _ values: (Int, Int, Int, Int)) -> BreakEntry {
        let calendar = Calendar.current
        let start = calendar.date(bySettingHour: values.0, minute: values.1, second: 0, of: date)!
        let end = calendar.date(bySettingHour: values.2, minute: values.3, second: 0, of: date)!
        return BreakEntry(start: start, end: end)
    }
}
