import SwiftUI

struct DailyTimeEntryListSectionHeader: View {
  var viewModel: TimeEntryListViewModel
  private static let durationStyle = Duration.TimeFormatStyle(pattern: .hourMinute)

  init(viewModel: TimeEntryListViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    HStack {
      if viewModel.timeEntries.isEmpty {
        Text("---")
      } else {
        Text(viewModel.timeEntries[0].timeEntry.start.formatted(date: .complete, time: .omitted))
      }
      Spacer()
      Text(viewModel.duration.formatted(DailyTimeEntryListSectionHeader.durationStyle))
    }
  }
}
