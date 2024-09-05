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
  let calendar = Calendar.current
  let from = calendar.date(from: DateComponents(year: 2024, month: 9, day: 5, hour: 5, minute: 30)) ?? Date.now
  let to = calendar.date(from: DateComponents(year: 2024, month: 9, day: 5, hour: 7, minute: 0)) ?? Date.now
  let container = Previewing.modelContainer

  return TimeEntryRow(timeEntry: TimeEntry(from: from, to: to, notes: "Some notes"))
    .modelContainer(container)
}
