import SwiftUI

struct TimeEntryRow : View {
  var viewModel: TimeEntryViewModel

  init(viewModel: TimeEntryViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    HStack {
      Text("\(Formatting.startEndFormatter.string(from: viewModel.timeEntry.start)) - \(Formatting.startEndFormatter.string(from: viewModel.timeEntry.end))")
      Spacer()
      Text(Formatting.timeIntervalFormatter.string(from: viewModel.timeEntry.onTheClock) ?? "")
    }
  }
}
