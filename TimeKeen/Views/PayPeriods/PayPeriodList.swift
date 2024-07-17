import SwiftUI

struct PayPeriodList: View {
  @ObservedObject var viewModel: PayPeriodListViewModel
  private let dateFormat: DateFormatter
  private static let durationStyle = Duration.TimeFormatStyle(pattern: .hourMinute)

  init(viewModel: PayPeriodListViewModel) {
    self.viewModel = viewModel
    dateFormat = DateFormatter()
    dateFormat.dateStyle = .medium
    dateFormat.timeStyle = .none
  }
  
  var body: some View {
    List(viewModel.payPeriods) { payPeriod in
      HStack {
        Text("\(dateFormat.string(from: payPeriod.payPeriodStart)) - \(dateFormat.string(from: payPeriod.payPeriodEnd))")
        Spacer()
        Text(payPeriod.duration.formatted(PayPeriodList.durationStyle))
      }
    }
    .onAppear(perform: viewModel.fetchData)
  }
}
