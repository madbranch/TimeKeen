import Foundation
import AppIntents

final class TimeKeenShortcuts: AppShortcutsProvider {
    @MainActor private static var dateProvider: DateProvider = RealDateProvider()
    
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: ClockIn(), phrases: [
            "Clock in in ${applicationName}",
            "Start working in ${applicationName}"
        ],
                    shortTitle: "Clock In",
                    systemImageName: "stopwatch")
        
        AppShortcut(intent: ClockOut(), phrases: [
            "Clock out in ${applicationName}",
            "Stop working in ${applicationName}"
        ],
                    shortTitle: "Clock Out",
                    systemImageName: "stopwatch")
    }
    
    @MainActor static func updateAppShortcutParameters(_ dateProvider: DateProvider) {
        TimeKeenShortcuts.dateProvider = dateProvider
        TimeKeenShortcuts.updateAppShortcutParameters()
    }
}
