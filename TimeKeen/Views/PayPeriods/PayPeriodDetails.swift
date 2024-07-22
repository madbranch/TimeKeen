import SwiftUI

struct PayPeriodDetails: View {
  var viewModel: PayPeriodViewModel

  init(viewModel: PayPeriodViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    List(viewModel.dailyTimeEntryLists) { dailyTimeEntryList in
      PayPeriodSection(viewModel: dailyTimeEntryList)
    }
    .navigationDestination(for: TimeEntryViewModel.self) { timeEntry in
      TimeEntryDetails(viewModel: timeEntry)
    }
    .navigationTitle("\(Formatting.yearlessDateformatter.string(from: viewModel.payPeriodStart)) - \(Formatting.yearlessDateformatter.string(from: viewModel.payPeriodEnd))")
  }
}
