import Foundation
import SwiftData

final class CurrentTimeEntryViewModel: ObservableObject {
  @Published var clockInDate = Date()
  @Published var clockInState: ClockInState = .clockedOut

  private var context: ModelContext
  
  init(context: ModelContext, clockedInAt clockInDate: Date? = nil) {
    self.context = context
    
    guard clockInDate != nil else {
      return
    }
    
    if let startingClockinDate = clockInDate {
      self.clockInDate = startingClockinDate
      clockInState = .clockedIn(.working)
    }
  }
  
  func clockIn(at clockInDate: Date) {
    switch clockInState {
    case .clockedIn(_):
      return
    case .clockedOut:
      self.clockInDate = clockInDate
      clockInState = .clockedIn(.working)
      UserDefaults.standard.set(clockInDate, forKey: "ClockInDate")
    }
  }
  
  func startBreak(at breakStart: Date) {
    switch clockInState {
    case .clockedOut:
      return
    case .clockedIn(let breakState):
      switch breakState {
      case .takingABreak:
        return
      case .working:
        // todo: start break...
        clockInState = .clockedIn(.takingABreak)
      }
    }
  }
  
  func endBreak(at breakEnd: Date) {
    switch clockInState {
    case .clockedOut:
      return
    case .clockedIn(let breakState):
      switch breakState {
      case .takingABreak:
        // todo: end break...
        clockInState = .clockedIn(.working)
      case .working:
        return
      }
    }
  }
  
  func clockOut(at end: Date, notes: String) -> Result<TimeEntry, ClockOutError> {
    switch clockInState {
    case .clockedIn(_):
      return .failure(.notClockedIn)
    case .clockedOut:
      guard clockInDate != end else {
        return .failure(.startAndEndEqual)
      }
      
      let timeEntry = TimeEntry(from: clockInDate, to: end, notes: notes)
      
      context.insert(timeEntry)

      clockInState = .clockedOut
      UserDefaults.standard.removeObject(forKey: "ClockInDate")

      return .success(timeEntry)
    }
  }
}
