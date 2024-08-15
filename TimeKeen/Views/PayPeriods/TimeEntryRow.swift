import SwiftUI

struct TimeEntryRow : View {
  var timeEntry: TimeEntry

  init(timeEntry: TimeEntry) {
    self.timeEntry = timeEntry
  }

  var body: some View {
    HStack {
      Text("\(Formatting.startEndFormatter.string(from: timeEntry.start)) - \(Formatting.startEndFormatter.string(from: timeEntry.end))")
      Spacer()
      Text(Formatting.timeIntervalFormatter.string(from: timeEntry.onTheClock) ?? "")
    }
  }
}
