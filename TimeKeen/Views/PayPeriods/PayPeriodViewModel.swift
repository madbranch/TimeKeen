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
  var dailyTimeEntryLists = [[TimeEntry]]()
  var nbEntries = 0
  var onTheClock = TimeInterval.zero
  
  init(from payPeriodStart: Date, to payPeriodEnd: Date, with dailyTimeEntryLists: [[TimeEntry]], context: ModelContext) {
    self.context = context
    self.payPeriodStart = payPeriodStart
    self.payPeriodEnd = payPeriodEnd
    self.dailyTimeEntryLists = dailyTimeEntryLists
  }
  
  func computeProperties() {
    var nbEntries = 0
    var onTheClock = TimeInterval.zero
    
    for dailyTimeEntryList in dailyTimeEntryLists {
      nbEntries += dailyTimeEntryList.count
      onTheClock += dailyTimeEntryList.reduce(TimeInterval.zero) { $0 + $1.onTheClock }
    }
    
    self.nbEntries = nbEntries
    self.onTheClock = onTheClock
  }
}
