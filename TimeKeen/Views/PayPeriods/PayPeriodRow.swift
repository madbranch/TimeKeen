import SwiftUI

struct PayPeriodRow: View {
  var viewModel: PayPeriodViewModel

  init(viewModel: PayPeriodViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text("\(Formatting.yearlessDateformatter.string(from: viewModel.payPeriodStart)) - \(Formatting.yearlessDateformatter.string(from: viewModel.payPeriodEnd))")
          .font(.headline)
        Text(viewModel.nbEntries == 1 ? "1 entry" : "\(viewModel.nbEntries) entries")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      Spacer()
      Text(Formatting.timeIntervalFormatter.string(from: viewModel.onTheClock) ?? "")
        .foregroundStyle(.secondary)
    }
  }
}
