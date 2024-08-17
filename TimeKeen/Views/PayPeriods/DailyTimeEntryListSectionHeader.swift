import SwiftUI

struct DailyTimeEntryListSectionHeader: View {
  @State var timeEntries: [TimeEntry]
  
  init(timeEntries: [TimeEntry]) {
    self.timeEntries = timeEntries
  }

  var body: some View {
    HStack {
      if timeEntries.isEmpty {
        Text("---")
      } else {
        Text(timeEntries[0].start.formatted(date: .complete, time: .omitted))
      }
      Spacer()
      Text(Formatting.timeIntervalFormatter.string(from: timeEntries.reduce(TimeInterval.zero) { $0 + $1.onTheClock }) ?? "")
    }
  }
}
