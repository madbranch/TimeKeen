import SwiftUI

struct PayPeriodDetails: View {
  @ObservedObject var viewModel: PayPeriodViewModel
  private let dateFormat: DateFormatter

  init(viewModel: PayPeriodViewModel) {
    self.viewModel = viewModel
    dateFormat = DateFormatter()
    dateFormat.locale = Locale.current
    dateFormat.setLocalizedDateFormatFromTemplate("MMM d")
  }

  var body: some View {
    List(viewModel.dailyTimeEntryLists) { dailyTimeEntryList in
      PayPeriodSection(viewModel: dailyTimeEntryList)
    }
    .navigationTitle("\(dateFormat.string(from: viewModel.payPeriodStart)) - \(dateFormat.string(from: viewModel.payPeriodEnd))")
  }
}
