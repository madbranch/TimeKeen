import Foundation
import SwiftUI
import SwiftData

@Observable class TimeEntryViewModel: Identifiable, Hashable {
  static func == (lhs: TimeEntryViewModel, rhs: TimeEntryViewModel) -> Bool {
    return lhs.timeEntry == rhs.timeEntry
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(timeEntry)
  }

  private var context: ModelContext
  var timeEntry: TimeEntry
  
  init(context: ModelContext, timeEntry: TimeEntry) {
    self.context = context
    self.timeEntry = timeEntry
  }
  
  func deleteBreaks(at offsets: IndexSet) {
    timeEntry.breaks.remove(atOffsets: offsets)
  }
}
