import SwiftUI

struct PayPeriodRow: View {
  var viewModel: PayPeriodViewModel
  private static let durationStyle = Duration.TimeFormatStyle(pattern: .hourMinute)

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
      Text(viewModel.duration.formatted(PayPeriodRow.durationStyle))
        .foregroundStyle(.secondary)
    }
  }
}
