import Foundation
import CoreData

final class TimePeriodsViewModel: ObservableObject {
  private var context: NSManagedObjectContext

  init(context: NSManagedObjectContext) throws {
    self.context = context
    
    let fetchRequest: NSFetchRequest<TimeEntry>
    fetchRequest = TimeEntry.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "start", ascending: false)]
    
    //let entries = try context.fetch(fetchRequest)
  }
}
