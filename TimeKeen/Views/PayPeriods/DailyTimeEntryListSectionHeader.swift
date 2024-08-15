import SwiftUI

struct DailyTimeEntryListSectionHeader: View {
  var viewModel: TimeEntryListViewModel

  init(viewModel: TimeEntryListViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    HStack {
      if viewModel.timeEntries.isEmpty {
        Text("---")
      } else {
        Text(viewModel.timeEntries[0].start.formatted(date: .complete, time: .omitted))
      }
      Spacer()
      Text(Formatting.timeIntervalFormatter.string(from: viewModel.onTheClock) ?? "")
    }
  }
}
