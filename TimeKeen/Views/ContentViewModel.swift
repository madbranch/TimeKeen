import Foundation

@Observable class ContentViewModel {
  var currentTimeEntryViewModel: CurrentTimeEntryViewModel
  var payPeriodListViewModel: PayPeriodListViewModel
  var settingsViewModel: SettingsViewModel
  
  init(currentTimeEntryViewModel: CurrentTimeEntryViewModel, payPeriodListViewModel: PayPeriodListViewModel, settingsViewModel: SettingsViewModel) {
    self.currentTimeEntryViewModel = currentTimeEntryViewModel
    self.payPeriodListViewModel = payPeriodListViewModel
    self.settingsViewModel = settingsViewModel
  }
}
