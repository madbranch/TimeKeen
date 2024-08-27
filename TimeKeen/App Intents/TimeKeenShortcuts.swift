import Foundation
import AppIntents

class TimeKeenShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(intent: ClockIn(), phrases: [
      "Clock In",
      "Start working"
    ],
    shortTitle: "Clock In",
    systemImageName: "stopwatch")
  }
}
