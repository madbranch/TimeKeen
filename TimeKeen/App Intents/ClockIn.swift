import Foundation
import AppIntents

struct ClockIn: AppIntent {
  static var title: LocalizedStringResource = "Clock In"
  static var description = IntentDescription("Clock in and start working.")
  
  @MainActor
  func perform() async throws -> some IntentResult {
    guard let userDefaults = SharedData.userDefaults else {
      return .result()
    }
    
    guard userDefaults.clockInState == .clockedOut else {
      return .result()
    }
    
    let minuteInterval = userDefaults.minuteInterval
    let clockInDate = Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: Date())
    
    userDefaults.notes = ""
    userDefaults.breaks = [BreakEntry]()
    userDefaults.clockInDate = clockInDate
    userDefaults.clockInState = .clockedInWorking
    
    return .result()
  }
}
