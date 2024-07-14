import Foundation
import SwiftData

final class CurrentTimeEntryViewModel: ObservableObject {
  @Published var clockInDate = Date()
  @Published var clockInState: ClockInState = .ClockedOut
  @Published var clockOutDate = Date()
  @Published var minClockOutDate = Date()

  private var context: ModelContext
  
  init(context: ModelContext, start: Date? = nil) {
    self.context = context
    
    if let clockInDate = start {
      self.clockInDate = clockInDate
      clockInState = .ClockedIn
    }
  }
  
  func startClockIn() {
    clockInDate = Date()
    clockInState = .ClockingIn
  }
  
  func commitClockIn() {
    clockInState = .ClockedIn
    UserDefaults.standard.set(clockInDate, forKey: "ClockInDate")
  }
  
  func startClockOut() {
    guard let newDate = Calendar.current.date(byAdding: .minute, value: 15, to: clockInDate) else {
      return
    }
    minClockOutDate = newDate
    clockOutDate = newDate
    clockInState = .ClockingOut
  }
  
  func commitClockOut() {
    _ = clockOut(at: clockOutDate)
  }
  
  func clockOut(at end: Date) -> Result<TimeEntry, ClockOutError> {
    guard clockInState == .ClockingOut else {
      return .failure(.notClockingOut)
    }
    
    guard clockInDate != end else {
      return .failure(.startAndEndEqual)
    }
    
    let timeEntry = TimeEntry(from: clockInDate, to: end)
    
    context.insert(timeEntry)

    clockInState = .ClockedOut
    UserDefaults.standard.removeObject(forKey: "ClockInDate")

    return .success(timeEntry)
  }
}
