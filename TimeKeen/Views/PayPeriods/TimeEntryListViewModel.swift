import Foundation
import SwiftUI
import SwiftData

final class TimeEntryListViewModel: ObservableObject {
  private var context: ModelContext
  @Published var timeEntries = [TimeEntry]()
  @Published var duration: Duration = .zero

  init(timeEntries: [TimeEntry], context: ModelContext) {
    self.context = context
    self.timeEntries = timeEntries
  }
  
  func computeProperties()
  {
    duration = timeEntries.reduce(Duration.zero, { result, timeEntry in result + timeEntry.duration })
  }
}
