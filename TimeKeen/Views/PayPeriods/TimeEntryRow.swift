import SwiftUI

struct TimeEntryRow : View {
  @Environment(\.modelContext) private var context
  var timeEntry: TimeEntry
  private let dateFormat: DateFormatter
  private static let durationStyle = Duration.TimeFormatStyle(pattern: .hourMinute)

  init(timeEntry: TimeEntry) {
    self.timeEntry = timeEntry
    dateFormat = DateFormatter()
    dateFormat.dateFormat = "HH:mm"
  }

  var body: some View {
    HStack {
      Text("\(self.dateFormat.string(from: timeEntry.start)) - \(self.dateFormat.string(from: timeEntry.end))")
      Spacer()
      Text(timeEntry.duration.formatted(TimeEntryRow.durationStyle))
    }
    .swipeActions {
      Button("Delete", systemImage: "trash", role: .destructive) {
        context.delete(timeEntry)
      }
    }
  }
}
