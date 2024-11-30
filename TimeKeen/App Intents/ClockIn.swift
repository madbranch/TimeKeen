import Foundation
import AppIntents
import WidgetKit

struct ClockIn: AppIntent, WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Clock In"
    static let description = IntentDescription("Clock in and start working.")
    
    @Parameter(title: "When", description: "When to clock in.")
    var when: Date?
    private let dateProvider: DateProvider
    
    init() {
        dateProvider = RealDateProvider()
    }
    
    init(dateProvider: DateProvider) {
        self.dateProvider = dateProvider
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let userDefaults = SharedData.userDefaults else {
            return .result(dialog: "Failed to clock in.")
        }
        
        guard userDefaults.clockInState == .clockedOut else {
            return .result(dialog: "You're already clocked in.")
        }
        
        var actualWhen = when
        
        if actualWhen == nil {
            do {
                actualWhen = try await $when.requestValue("When do you want to clock in?")
            } catch {
                return .result(dialog: "wut")
            }
        }
        
        let calendar = Calendar.current
        let clockInDate = calendar.getRoundedDate(minuteInterval: userDefaults.minuteInterval, from: actualWhen!)
        
        userDefaults.notes = ""
        userDefaults.breaks = [BreakEntry]()
        userDefaults.clockInDate = clockInDate
        userDefaults.clockInState = .clockedInWorking
        
        WidgetCenter.shared.reloadTimelines(ofKind: "TimeKeenWidgetExtension")

        return calendar.isDate(clockInDate, inSameDayAs: dateProvider.now)
        ? .result(dialog: "Clocking in at \(Formatting.startEndFormatter.string(from: clockInDate))")
        : .result(dialog: "Clocking in on \(Formatting.startEndWithDateFormatter.string(from: clockInDate))")
    }
}
