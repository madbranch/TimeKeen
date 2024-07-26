import Foundation
import SwiftUI
import SwiftData

@Observable class PayPeriodViewModel: Identifiable, Hashable {
  static func == (lhs: PayPeriodViewModel, rhs: PayPeriodViewModel) -> Bool {
    return lhs.dailyTimeEntryLists == rhs.dailyTimeEntryLists
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(dailyTimeEntryLists)
  }
  
  private var context: ModelContext
  var payPeriodStart: Date
  var payPeriodEnd: Date
  var dailyTimeEntryLists = [TimeEntryListViewModel]()
  var nbEntries = 0
  var onTheClock = TimeInterval.zero
  
  init(from payPeriodStart: Date, to payPeriodEnd: Date, with dailyTimeEntryLists: [TimeEntryListViewModel], context: ModelContext) {
    self.context = context
    self.payPeriodStart = payPeriodStart
    self.payPeriodEnd = payPeriodEnd
    self.dailyTimeEntryLists = dailyTimeEntryLists
  }
  
  func computeProperties() {
    var nbEntries = 0
    var onTheClock = TimeInterval.zero
    
    for dailyTimeEntryList in dailyTimeEntryLists {
      nbEntries += dailyTimeEntryList.timeEntries.count
      onTheClock = dailyTimeEntryList.timeEntries.reduce(TimeInterval.zero) { $0 + $1.timeEntry.onTheClock }
    }
    
    self.nbEntries = nbEntries
    self.onTheClock = onTheClock
  }
}
