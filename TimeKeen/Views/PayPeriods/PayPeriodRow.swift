import SwiftUI

struct PayPeriodRow: View {
  @ObservedObject var viewModel: PayPeriodViewModel
  private let dateFormat: DateFormatter
  private static let durationStyle = Duration.TimeFormatStyle(pattern: .hourMinute)

  init(viewModel: PayPeriodViewModel) {
    self.viewModel = viewModel
    dateFormat = DateFormatter()
    dateFormat.dateStyle = .medium
    dateFormat.timeStyle = .none
  }
  
  var body: some View {
    HStack {
      Text("\(dateFormat.string(from: viewModel.payPeriodStart)) - \(dateFormat.string(from: viewModel.payPeriodEnd))")
      Spacer()
      Text(viewModel.duration.formatted(PayPeriodRow.durationStyle))
    }
  }
}
