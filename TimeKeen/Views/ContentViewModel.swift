import Foundation

@Observable class ContentViewModel {
  var currentTimeEntryViewModel: CurrentTimeEntryViewModel
  var payPeriodListViewModel: PayPeriodListViewModel
  
  init(currentTimeEntryViewModel: CurrentTimeEntryViewModel, payPeriodListViewModel: PayPeriodListViewModel) {
    self.currentTimeEntryViewModel = currentTimeEntryViewModel
    self.payPeriodListViewModel = payPeriodListViewModel
  }
}
