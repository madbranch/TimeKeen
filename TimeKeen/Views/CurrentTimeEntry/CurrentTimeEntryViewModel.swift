import Foundation
import SwiftData

final class CurrentTimeEntryViewModel: ObservableObject {
  @Published var clockInDate = Date()
  @Published var clockInState: ClockInState = .ClockedOut

  private var context: ModelContext
  
  init(context: ModelContext, clockedInAt clockInDate: Date? = nil) {
    self.context = context
    
    guard clockInDate != nil else {
      return
    }
    
    if let startingClockinDate = clockInDate {
      self.clockInDate = startingClockinDate
      clockInState = .ClockedIn
    }
  }
  
  func clockIn(at clockInDate: Date) {
    self.clockInDate = clockInDate
    clockInState = .ClockedIn
    UserDefaults.standard.set(clockInDate, forKey: "ClockInDate")
  }
  
  func clockOut(at end: Date) -> Result<TimeEntry, ClockOutError> {
    guard clockInState == .ClockedIn else {
      return .failure(.notClockedIn)
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
