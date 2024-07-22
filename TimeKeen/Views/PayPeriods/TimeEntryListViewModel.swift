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
  var duration: Duration = .zero

  init(timeEntries: [TimeEntryViewModel], context: ModelContext) {
    self.context = context
    self.timeEntries = timeEntries
  }
  
  func computeProperties()
  {
    duration = timeEntries.reduce(Duration.zero, { result, timeEntry in result + timeEntry.timeEntry.duration })
  }
  
  func deleteTimeEntries(at offsets: IndexSet) {
    for index in offsets {
      context.delete(timeEntries[index].timeEntry)
    }
    timeEntries.remove(atOffsets: offsets)
    computeProperties()
  }
}
