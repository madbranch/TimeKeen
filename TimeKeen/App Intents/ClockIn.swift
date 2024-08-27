import Foundation
import AppIntents

struct ClockIn: AppIntent {
  static var title: LocalizedStringResource = "Clock In"
  static var description = IntentDescription("Clock in and start working.")
  
  @Parameter(title: "When", description: "When to clock in.")
  var when: Date
  
  @MainActor
  func perform() async throws -> some IntentResult & ProvidesDialog {
    guard let userDefaults = SharedData.userDefaults else {
      return .result(dialog: "Failed to clock in.")
    }
    
    guard userDefaults.clockInState == .clockedOut else {
      return .result(dialog: "You're already clocked in.")
    }
    
    let calendar = Calendar.current
    let clockInDate = calendar.getRoundedDate(minuteInterval: userDefaults.minuteInterval, from: when)
    
    userDefaults.notes = ""
    userDefaults.breaks = [BreakEntry]()
    userDefaults.clockInDate = clockInDate
    userDefaults.clockInState = .clockedInWorking
    
    return calendar.isDate(clockInDate, inSameDayAs: Date())
    ? .result(dialog: "Clocking in at \(Formatting.startEndFormatter.string(from: clockInDate))")
    : .result(dialog: "Clocking in on \(Formatting.startEndWithDateFormatter.string(from: clockInDate))")
  }
}
