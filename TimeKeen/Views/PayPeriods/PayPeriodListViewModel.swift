import Foundation
import SwiftUI
import SwiftData

@Observable class PayPeriodListViewModel {
  private var context: ModelContext
  var payPeriods = [PayPeriodViewModel]()
  var timeEntrySharingViewModel: TimeEntrySharingViewModel
  
  init(timeEntrySharingViewModel: TimeEntrySharingViewModel, context: ModelContext) {
    self.timeEntrySharingViewModel = timeEntrySharingViewModel
    self.context = context
  }
  
  func fetchTimeEntries(by schedule: PayPeriodSchedule, ending periodEnd: Date) {
    do {
      let descriptor = FetchDescriptor<TimeEntry>(sortBy: [SortDescriptor(\.start, order: .reverse)])
      let allTimeEntries = try context.fetch(descriptor)
      let calendar = Calendar.current
      let timeEntriesPerPayPeriod = allTimeEntries.group(by: schedule, ending: periodEnd)
      
      payPeriods = timeEntriesPerPayPeriod.keys.sorted(by: { $0.lowerBound >= $1.lowerBound } ).map { payPeriod in
        let payPeriodTimeEntries = timeEntriesPerPayPeriod[payPeriod]!
        let payPeriodStart = payPeriod.lowerBound
        let payPeriodEnd = payPeriod.upperBound
        
        let timeEntriesPerDay = Dictionary(grouping: payPeriodTimeEntries, by: {
          let year = calendar.component(.year, from: $0.start)
          let month = calendar.component(.month, from: $0.start)
          let day = calendar.component(.day, from: $0.start)
          return calendar.date(from: DateComponents(year: year, month: month, day: day))!
        })
        
        let newTimeEntryLists = timeEntriesPerDay.keys.sorted().reversed().map { timeEntriesDay in
          return timeEntriesPerDay[timeEntriesDay]!
        }
        
        let newPayPeriod = PayPeriodViewModel(from: payPeriodStart, to: payPeriodEnd, with: newTimeEntryLists, context: self.context)
        newPayPeriod.computeProperties()
        return newPayPeriod
      }
    } catch {
      print("Fetch failed")
    }
  }
}
