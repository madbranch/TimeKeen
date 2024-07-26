import Foundation
import SwiftUI
import SwiftData

@Observable class TimeEntryListViewModel: Identifiable, Hashable {
  static func == (lhs: TimeEntryListViewModel, rhs: TimeEntryListViewModel) -> Bool {
    return lhs.timeEntries == rhs.timeEntries
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(timeEntries)
  }
  
  private var context: ModelContext
  var timeEntries = [TimeEntryViewModel]()
  var onTheClock: TimeInterval = .zero

  init(timeEntries: [TimeEntryViewModel], context: ModelContext) {
    self.context = context
    self.timeEntries = timeEntries
  }
  
  func computeProperties()
  {
    onTheClock = timeEntries.reduce(TimeInterval.zero) { $0 + $1.timeEntry.onTheClock }
  }
  
  func deleteTimeEntries(at offsets: IndexSet) {
    for index in offsets {
      context.delete(timeEntries[index].timeEntry)
    }
    timeEntries.remove(atOffsets: offsets)
    computeProperties()
  }
}
