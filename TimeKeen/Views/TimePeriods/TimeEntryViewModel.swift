import Foundation
import SwiftUI

final class TimeEntryViewModel: ObservableObject, Identifiable {
  @Published var timeEntry: TimeEntry
  
  init(timeEntry: TimeEntry) {
    self.timeEntry = timeEntry
  }
}
