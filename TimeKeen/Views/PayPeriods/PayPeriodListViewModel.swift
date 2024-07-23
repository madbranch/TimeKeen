import Foundation
import SwiftUI
import SwiftData

@Observable class PayPeriodListViewModel {
  private var context: ModelContext
  var payPeriods = [PayPeriodViewModel]()
  
  init(context: ModelContext) {
    self.context = context
  }
  
  func fetchTimeEntries(by schedule: PayPeriodSchedule, ending periodEnd: Date) {
    do {
      let descriptor = FetchDescriptor<TimeEntry>(sortBy: [SortDescriptor(\.start, order: .reverse)])
      let allTimeEntries = try context.fetch(descriptor)
      
      let calendar = Calendar.current
      
      let timeEntriesPerPayPeriod = allTimeEntries.group(by: schedule, ending: periodEnd)
      
      var newPayPeriods = [PayPeriodViewModel]()
      newPayPeriods.reserveCapacity(timeEntriesPerPayPeriod.count)
      
      for payPeriod in timeEntriesPerPayPeriod.keys.sorted(by: { $0.lowerBound >= $1.lowerBound } ) {
        let payPeriodTimeEntries = timeEntriesPerPayPeriod[payPeriod]!
        let payPeriodStart = payPeriod.lowerBound
        let payPeriodEnd = payPeriod.upperBound
        
        let timeEntriesPerDay = Dictionary(grouping: payPeriodTimeEntries, by: {
          let year = calendar.component(.year, from: $0.start)
          let month = calendar.component(.month, from: $0.start)
          let day = calendar.component(.day, from: $0.start)
          return calendar.date(from: DateComponents(year: year, month: month, day: day))!
        })
        
        var newTimeEntryLists = [TimeEntryListViewModel]()
        newTimeEntryLists.reserveCapacity(timeEntriesPerDay.count)
        
        for timeEntriesDay in timeEntriesPerDay.keys.sorted().reversed() {
          let dailyTimeEntries = timeEntriesPerDay[timeEntriesDay]!.map { TimeEntryViewModel(context: context, timeEntry: $0 ) }
          
          newTimeEntryLists.append(TimeEntryListViewModel(timeEntries: dailyTimeEntries, context: self.context))
        }
        
        let newPayPeriod = PayPeriodViewModel(from: payPeriodStart, to: payPeriodEnd, with: newTimeEntryLists, context: self.context)
        newPayPeriod.computeProperties()
        newPayPeriods.append(newPayPeriod)
      }
      
      payPeriods = newPayPeriods
    } catch {
      print("Fetch failed")
    }
  }
}
