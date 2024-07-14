import Foundation
import SwiftUI
import CoreData

final class TimePeriodsViewModel: ObservableObject {
  private var context: NSManagedObjectContext
  @FetchRequest(fetchRequest: requestEntries) private var entries: FetchedResults<TimeEntry>

  init(context: NSManagedObjectContext) throws {
    self.context = context
  }

  static let requestEntries: NSFetchRequest = {
    let request = TimeEntry.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "start", ascending: false)]
    return request
  }()
}
