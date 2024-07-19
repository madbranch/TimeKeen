import Foundation
import SwiftUI
import SwiftData

final class PayPeriodListViewModel: ObservableObject {
  private var context: ModelContext
  @Published var payPeriods = [PayPeriodViewModel]()
  
  init(context: ModelContext) {
    self.context = context
  }
  
  func fetchTimeEntries() {
    do {
      let descriptor = FetchDescriptor<TimeEntry>(sortBy: [SortDescriptor(\.start, order: .reverse)])
      let allTimeEntries = try context.fetch(descriptor)
      
      var calendar = Calendar(identifier: Calendar.current.identifier)
      
      calendar.firstWeekday = 2
      
      let timeEntriesPerPayPeriod = Dictionary(grouping: allTimeEntries, by: {
        let yearForWeekOfYear = calendar.component(.yearForWeekOfYear, from: $0.start)
        let weekOfYear = calendar.component(.weekOfYear, from: $0.start)
        return calendar.date(from: DateComponents(weekOfYear: weekOfYear, yearForWeekOfYear: yearForWeekOfYear))!
      })
      
      var newPayPeriods = [PayPeriodViewModel]()
      newPayPeriods.reserveCapacity(timeEntriesPerPayPeriod.count)
      
      for payPeriodStart in timeEntriesPerPayPeriod.keys.sorted().reversed() {
        let payPeriodTimeEntries = timeEntriesPerPayPeriod[payPeriodStart]!
        let payPeriodEnd = calendar.date(byAdding: .day, value: 6, to: payPeriodStart)!
        
        let timeEntriesPerDay = Dictionary(grouping: payPeriodTimeEntries, by: {
          let year = calendar.component(.year, from: $0.start)
          let month = calendar.component(.month, from: $0.start)
          let day = calendar.component(.day, from: $0.start)
          return calendar.date(from: DateComponents(year: year, month: month, day: day))!
        })
        
        var newTimeEntryLists = [TimeEntryListViewModel]()
        newTimeEntryLists.reserveCapacity(timeEntriesPerDay.count)
        
        for timeEntriesDay in timeEntriesPerDay.keys.sorted().reversed() {
          let dailyTimeEntries = timeEntriesPerDay[timeEntriesDay]!
          
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
