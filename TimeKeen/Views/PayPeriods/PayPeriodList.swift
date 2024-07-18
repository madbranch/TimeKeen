import SwiftUI

struct PayPeriodList: View {
  @ObservedObject var viewModel: PayPeriodListViewModel

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
    .navigationTitle("Pay Periods")
    .onAppear(perform: viewModel.fetchData)
  }
}
