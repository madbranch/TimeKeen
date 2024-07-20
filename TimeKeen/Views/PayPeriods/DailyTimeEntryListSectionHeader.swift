import SwiftUI

struct DailyTimeEntryListSectionHeader: View {
  @ObservedObject var viewModel: TimeEntryListViewModel
  private static let durationStyle = Duration.TimeFormatStyle(pattern: .hourMinute)

  init(viewModel: TimeEntryListViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    HStack {
      Text(viewModel.timeEntries[0].timeEntry.start.formatted(date: .complete, time: .omitted))
      Spacer()
      Text(viewModel.duration.formatted(DailyTimeEntryListSectionHeader.durationStyle))
    }
  }
}
