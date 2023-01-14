import Foundation
import CoreData

final class CurrentTimeEntryViewModel: ObservableObject {
  @Published var start: Date?
  
  private var context: NSManagedObjectContext
  
  init(context: NSManagedObjectContext) {
    self.context = context
  }
  
  func clockOut(at end: Date) -> Result<TimeEntry, ClockOutError> {
    guard let start = self.start else {
      return .failure(.notStarted)
    }
    
    guard start != end else {
      return .failure(.startAndEndEqual)
    }
    
    let entry = TimeEntry(context: context)
    entry.start = start
    entry.end = end
    
    self.start = nil
    
    return .success(entry)
  }
}
