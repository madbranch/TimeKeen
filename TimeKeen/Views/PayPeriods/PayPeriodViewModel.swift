import Foundation
import SwiftUI
import SwiftData

final class PayPeriodViewModel: ObservableObject, Identifiable, Hashable {
  static func == (lhs: PayPeriodViewModel, rhs: PayPeriodViewModel) -> Bool {
    return lhs.dailyTimeEntryLists == rhs.dailyTimeEntryLists
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(dailyTimeEntryLists)
  }
  
  private var context: ModelContext
  @Published var payPeriodStart: Date
  @Published var payPeriodEnd: Date
  @Published var dailyTimeEntryLists = [TimeEntryListViewModel]()
  @Published var nbEntries = 0
  @Published var duration: Duration = .zero
  
  init(from payPeriodStart: Date, to payPeriodEnd: Date, with dailyTimeEntryLists: [TimeEntryListViewModel], context: ModelContext) {
    self.context = context
    self.payPeriodStart = payPeriodStart
    self.payPeriodEnd = payPeriodEnd
    self.dailyTimeEntryLists = dailyTimeEntryLists
  }
  
  func computeProperties() {
    var nbEntries = 0
    var duration: Duration = .zero
    
    for dailyTimeEntryList in dailyTimeEntryLists {
      nbEntries += dailyTimeEntryList.timeEntries.count
      
      for timeEntry in dailyTimeEntryList.timeEntries {
        duration = .seconds(duration.components.seconds + timeEntry.timeEntry.duration.components.seconds)
      }
    }
    
    self.nbEntries = nbEntries
    self.duration = duration
  }
}
