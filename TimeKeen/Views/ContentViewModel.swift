import Foundation

final class ContentViewModel: ObservableObject {
  @Published var currentTimeEntryViewModel: CurrentTimeEntryViewModel
  @Published var payPeriodListViewModel: PayPeriodListViewModel
  
  init(currentTimeEntryViewModel: CurrentTimeEntryViewModel, payPeriodListViewModel: PayPeriodListViewModel) {
    self.currentTimeEntryViewModel = currentTimeEntryViewModel
    self.payPeriodListViewModel = payPeriodListViewModel
  }
}
