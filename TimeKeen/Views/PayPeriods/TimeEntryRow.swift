import SwiftUI
import SwiftData

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
        .foregroundStyle(.secondary)
    }
  }
}

#Preview {
  let container = Previewing.modelContainer
  let timeEntry = Previewing.someTimeEntry

  return TimeEntryRow(timeEntry: timeEntry)
    .modelContainer(container)
}
