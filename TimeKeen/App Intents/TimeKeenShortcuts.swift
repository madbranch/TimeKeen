import Foundation
import AppIntents

class TimeKeenShortcuts: AppShortcutsProvider {
    @MainActor private static var dateProvider: DateProvider = RealDateProvider()
    
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: ClockIn(), phrases: [
            "Clock in",
            "Start working"
        ],
                    shortTitle: "Clock In",
                    systemImageName: "stopwatch")
        
        AppShortcut(intent: ClockOut(), phrases: [
            "Clock out",
            "Stop working"
        ],
                    shortTitle: "Clock Out",
                    systemImageName: "stopwatch")
    }
    
    @MainActor static func updateAppShortcutParameters(_ dateProvider: DateProvider) {
        TimeKeenShortcuts.dateProvider = dateProvider
        TimeKeenShortcuts.updateAppShortcutParameters()
    }
}
