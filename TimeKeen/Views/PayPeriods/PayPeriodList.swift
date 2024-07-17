import SwiftUI

struct PayPeriodList: View {
  @ObservedObject var viewModel: PayPeriodListViewModel

  init(viewModel: PayPeriodListViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    List(viewModel.payPeriods) { payPeriod in
      PayPeriodRow(viewModel: payPeriod)
    }
    .onAppear(perform: viewModel.fetchData)
  }
}
