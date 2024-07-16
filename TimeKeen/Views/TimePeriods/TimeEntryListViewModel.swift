import Foundation
import SwiftUI
import SwiftData

final class TimeEntryListViewModel: ObservableObject {
  private var context: ModelContext
  @Published var timeEntries = [TimeEntry]()

  init(context: ModelContext) {
    self.context = context
  }
  
  func fetchData()
  {
    do {
      let descriptor = FetchDescriptor<TimeEntry>(sortBy: [SortDescriptor(\.start, order: .reverse)])
      timeEntries = try context.fetch(descriptor)
    } catch {
      print("Fetch failed")
    }
  }
}
