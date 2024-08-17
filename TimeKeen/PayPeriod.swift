import Foundation

struct PayPeriod: Identifiable, Hashable {
  var id: ClosedRange<Date> { return range }
  
  var range: ClosedRange<Date>
  var timeEntries: [TimeEntry]
  
  init(range: ClosedRange<Date>, timeEntries: [TimeEntry]) {
    self.range = range
    self.timeEntries = timeEntries
  }
}
