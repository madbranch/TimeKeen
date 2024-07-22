import SwiftUI

struct TimeEntryRow : View {
  var viewModel: TimeEntryViewModel
  private static let durationStyle = Duration.TimeFormatStyle(pattern: .hourMinute)

  init(viewModel: TimeEntryViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    HStack {
      Text("\(Formatting.startEndFormatter.string(from: viewModel.timeEntry.start)) - \(Formatting.startEndFormatter.string(from: viewModel.timeEntry.end))")
      Spacer()
      Text(viewModel.timeEntry.duration.formatted(TimeEntryRow.durationStyle))
    }
  }
}
