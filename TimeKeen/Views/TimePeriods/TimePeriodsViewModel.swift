import Foundation
import SwiftUI
import SwiftData

final class TimePeriodsViewModel: ObservableObject {
  private var context: ModelContext
  @Published var timeEntries = [TimeEntry]()

  init(context: ModelContext) {
    self.context = context
  }
  
  func fetchData()
  {
    do {
      let descriptor = FetchDescriptor<TimeEntry>(sortBy: [SortDescriptor(\.start)])
      timeEntries = try context.fetch(descriptor)
    } catch {
      print("Fetch failed")
    }
  }
}
