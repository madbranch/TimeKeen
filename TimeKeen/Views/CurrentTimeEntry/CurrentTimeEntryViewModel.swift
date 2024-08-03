import Foundation
import SwiftData

@Observable class CurrentTimeEntryViewModel {
  var clockInDate = Date()
  var clockInState: ClockInState = .clockedOut
  var breakStart = Date()
  var breaks = [BreakItem]()
  private let userDefaults: UserDefaults

  private var context: ModelContext
  
  init(context: ModelContext, clockedInAt clockInDate: Date? = nil, startedBreakAt breakStart: Date? = nil, withBreaks breaks: [BreakItem]? = nil, userDefaults: UserDefaults) {
    self.context = context
    
    if let startingClockinDate = clockInDate {
      self.clockInDate = startingClockinDate

      if let startingBreaks = breaks {
        self.breaks = startingBreaks
      }

      if let startingBreakStart = breakStart {
        self.breakStart = startingBreakStart
        clockInState = .clockedIn(.takingABreak)
      } else {
        clockInState = .clockedIn(.working)
      }
    }
    
    self.userDefaults = userDefaults
  }
  
  func clockIn(at clockInDate: Date) {
    switch clockInState {
    case .clockedIn(_):
      return
    case .clockedOut:
      self.clockInDate = clockInDate
      breaks.removeAll()
      clockInState = .clockedIn(.working)
      userDefaults.set(clockInDate, forKey: "ClockInDate")
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
        self.breakStart = breakStart
        clockInState = .clockedIn(.takingABreak)
        userDefaults.set(breakStart, forKey: "BreakStart")
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
        self.breaks.append(BreakItem(start: breakStart, end: breakEnd))
        clockInState = .clockedIn(.working)
        userDefaults.removeObject(forKey: "BreakStart")
        
        if let encodedBreaks = try? JSONEncoder().encode(breaks) {
          userDefaults.set(encodedBreaks, forKey: "Breaks")
        }
      case .working:
        return
      }
    }
  }
  
  func clockOut(at end: Date, notes: String) -> Result<TimeEntry, ClockOutError> {
    switch clockInState {
    case .clockedOut:
      return .failure(.notClockedIn)
    case .clockedIn(let breakState):
      switch breakState {
      case .takingABreak:
        return .failure(.notWorking)
      case .working:
        guard clockInDate != end else {
          return .failure(.startAndEndEqual)
        }
        
        let timeEntry = TimeEntry(from: clockInDate, to: end, notes: notes)
        
        timeEntry.breaks.append(contentsOf: breaks.map { BreakEntry(start: $0.start, end: $0.end) })
        
        context.insert(timeEntry)

        clockInState = .clockedOut
        userDefaults.removeObject(forKey: "ClockInDate")
        userDefaults.removeObject(forKey: "Breaks")

        return .success(timeEntry)
      }
    }
  }
}
