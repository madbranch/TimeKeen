import SwiftUI

struct TimeEntryRow : View {
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
      Text("\(dateFormat.string(from: timeEntry.start)) - \(dateFormat.string(from: timeEntry.end))")
      Spacer()
      Text(timeEntry.duration.formatted(TimeEntryRow.durationStyle))
    }
  }
}
