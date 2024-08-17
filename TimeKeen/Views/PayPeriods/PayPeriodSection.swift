import SwiftUI

struct PayPeriodSection: View {
  var timeEntries: [TimeEntry]
  
  init(timeEntries: [TimeEntry]) {
    self.timeEntries = timeEntries
  }
  
  var body: some View {
    Section(content: { TimeEntryList(timeEntries: timeEntries) },
            header: { DailyTimeEntryListSectionHeader(timeEntries: timeEntries) })
  }
}
