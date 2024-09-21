import Foundation
import SwiftData
import AppIntents

struct ClockOut: AppIntent {
    static let title: LocalizedStringResource = "Clock Out"
    static let description = IntentDescription("Clock out and stop working.")
    
    @Parameter(title: "When", description: "When to clock out.")
    var when: Date
    private let dateProvider: DateProvider
    
    init() {
        dateProvider = RealDateProvider()
    }
    
    init(dateProvider: DateProvider) {
        self.dateProvider = dateProvider
    }
    
    @Dependency
    private var modelContainer: ModelContainer
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let userDefaults = SharedData.userDefaults else {
            return .result(dialog: "Failed to clock out.")
        }
        
        guard userDefaults.clockInState == .clockedInWorking else {
            return .result(dialog: "You're not working.")
        }
        
        guard let clockInDate = userDefaults.clockInDate else {
            return .result(dialog: "You're not properly clocked in.")
        }
        
        let calendar = Calendar.current
        let clockOutDate = calendar.getRoundedDate(minuteInterval: userDefaults.minuteInterval, from: when)
        let timeEntry = TimeEntry(from: clockInDate, to: clockOutDate, notes: userDefaults.notes ?? "")
        timeEntry.breaks.append(contentsOf: userDefaults.breaks ?? [BreakEntry]())
        modelContainer.mainContext.insert(timeEntry)
        userDefaults.clockInState = .clockedOut
        
        return calendar.isDate(clockInDate, inSameDayAs: dateProvider.now)
        ? .result(dialog: "Clocking out at \(Formatting.startEndFormatter.string(from: clockOutDate))")
        : .result(dialog: "Clocking out on \(Formatting.startEndWithDateFormatter.string(from: clockOutDate))")
    }
}
