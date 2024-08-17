import Foundation
import SwiftData

@Observable class CurrentTimeEntryViewModel {
  var clockInDate = Date()
  var clockInState: ClockInState = .clockedOut
  var breakStart = Date()
  var breaks = [BreakItem]()
  var quickActionProvider: QuickActionProvider
  private let userDefaults: UserDefaults
  
  private var context: ModelContext
  
  init(context: ModelContext, clockedInAt clockInDate: Date? = nil, startedBreakAt breakStart: Date? = nil, withBreaks breaks: [BreakItem]? = nil, userDefaults: UserDefaults, quickActionProvider: QuickActionProvider) {
    self.context = context
    
    if let startingClockinDate = clockInDate {
      self.clockInDate = startingClockinDate
      
      if let startingBreaks = breaks {
        self.breaks = startingBreaks
      }
      
      if let startingBreakStart = breakStart {
        self.breakStart = startingBreakStart
        clockInState = .clockedInTakingABreak
      } else {
        clockInState = .clockedInWorking
      }
    }
    
    self.userDefaults = userDefaults
    self.quickActionProvider = quickActionProvider
  }
  
  func clockIn(at clockInDate: Date) {
    switch clockInState {
    case .clockedInWorking:
      return
    case .clockedInTakingABreak:
      return
    case .clockedOut:
      self.clockInDate = clockInDate
      breaks.removeAll()
      clockInState = .clockedInWorking
      userDefaults.set(clockInDate, forKey: "ClockInDate")
    }
  }
  
  func startBreak(at breakStart: Date) {
    switch clockInState {
    case .clockedOut:
      return
    case .clockedInWorking:
      self.breakStart = breakStart
      clockInState = .clockedInTakingABreak
      userDefaults.set(breakStart, forKey: "BreakStart")
      break
    case .clockedInTakingABreak:
      return
    }
  }
  
  func endBreak(at breakEnd: Date) {
    switch clockInState {
    case .clockedOut:
      return
    case .clockedInTakingABreak:
      self.breaks.append(BreakItem(start: breakStart, end: breakEnd))
      clockInState = .clockedInWorking
      userDefaults.removeObject(forKey: "BreakStart")
      
      if let encodedBreaks = try? JSONEncoder().encode(breaks) {
        userDefaults.set(encodedBreaks, forKey: "Breaks")
      }
      break
    case .clockedInWorking:
      return
    }
  }
  
  func clockOut(at end: Date, notes: String) -> Result<TimeEntry, ClockOutError> {
    switch clockInState {
    case .clockedOut:
      return .failure(.notClockedIn)
    case .clockedInTakingABreak:
      return .failure(.notWorking)
    case .clockedInWorking:
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
