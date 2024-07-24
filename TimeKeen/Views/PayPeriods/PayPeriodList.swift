import SwiftUI

struct PayPeriodList: View {
  var viewModel: PayPeriodListViewModel
  @AppStorage("PayPeriodSchedule") var payPeriodSchedule = PayPeriodSchedule.Weekly
  @AppStorage("EndOfLastPayPeriod") var endOfLastPayPeriod = Calendar.current.date(from: DateComponents(year: 2024, month: 07, day: 21))!

  init(viewModel: PayPeriodListViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    List(viewModel.payPeriods) { payPeriod in
      NavigationLink(value: payPeriod) {
        PayPeriodRow(viewModel: payPeriod)
      }
    }
    .navigationDestination(for: PayPeriodViewModel.self) { payPeriod in
      PayPeriodDetails(viewModel: payPeriod)
    }
    .onAppear() {
      viewModel.fetchTimeEntries(by: payPeriodSchedule, ending: endOfLastPayPeriod)
    }
    .overlay {
      if viewModel.payPeriods.isEmpty {
        ContentUnavailableView {
          Label("No Time Entries", systemImage: "clock")
        } description: {
          Text("Time you log will appear here.")
        }
      }
    }
  }
}
