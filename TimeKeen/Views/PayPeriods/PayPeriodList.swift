import SwiftUI

struct PayPeriodList: View {
  @ObservedObject var viewModel: PayPeriodListViewModel

  init(viewModel: PayPeriodListViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    List(viewModel.payPeriods) { payPeriod in
      NavigationLink {
        PayPeriodDetails(viewModel: payPeriod)
      } label: {
        PayPeriodRow(viewModel: payPeriod)
      }
    }
    .navigationTitle("Pay Periods")
    .onAppear(perform: viewModel.fetchData)
  }
}
