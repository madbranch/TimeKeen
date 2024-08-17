import SwiftUI

struct PayPeriodDetails: View {
  var viewModel: PayPeriodViewModel

  init(viewModel: PayPeriodViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    List(viewModel.dailyTimeEntryLists) { dailyTimeEntryList in
      PayPeriodSection(timeEntries: dailyTimeEntryList)
    }
    .navigationDestination(for: TimeEntry.self) { timeEntry in
      TimeEntryDetails(timeEntry: timeEntry)
    }
    .navigationTitle("\(Formatting.yearlessDateformatter.string(from: viewModel.payPeriodStart)) - \(Formatting.yearlessDateformatter.string(from: viewModel.payPeriodEnd))")
  }
}
