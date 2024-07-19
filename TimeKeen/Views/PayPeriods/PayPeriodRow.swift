import SwiftUI

struct PayPeriodRow: View {
  @ObservedObject var viewModel: PayPeriodViewModel
  private let dateFormat: DateFormatter
  private static let durationStyle = Duration.TimeFormatStyle(pattern: .hourMinute)

  init(viewModel: PayPeriodViewModel) {
    self.viewModel = viewModel
    dateFormat = DateFormatter()
    dateFormat.locale = Locale.current
    dateFormat.setLocalizedDateFormatFromTemplate("MMM d")
  }
  
  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text("\(dateFormat.string(from: viewModel.payPeriodStart)) - \(dateFormat.string(from: viewModel.payPeriodEnd))")
          .font(.headline)
        Text(viewModel.nbEntries == 1 ? "1 entry" : "\(viewModel.nbEntries) entries")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      Spacer()
      Text(viewModel.duration.formatted(PayPeriodRow.durationStyle))
    }
  }
}
