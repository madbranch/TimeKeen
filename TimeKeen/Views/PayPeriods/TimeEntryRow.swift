import SwiftUI

struct TimeEntryRow : View {
  var viewModel: TimeEntryViewModel
  private let dateFormat: DateFormatter
  private static let durationStyle = Duration.TimeFormatStyle(pattern: .hourMinute)

  init(viewModel: TimeEntryViewModel) {
    self.viewModel = viewModel
    dateFormat = DateFormatter()
    dateFormat.dateFormat = "HH:mm"
  }

  var body: some View {
    HStack {
      Text("\(dateFormat.string(from: viewModel.timeEntry.start)) - \(dateFormat.string(from: viewModel.timeEntry.end))")
      Spacer()
      Text(viewModel.timeEntry.duration.formatted(TimeEntryRow.durationStyle))
    }
  }
}
