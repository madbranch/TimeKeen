import Foundation

@Observable class ContentViewModel {
  var currentTimeEntryViewModel: CurrentTimeEntryViewModel
  
  init(currentTimeEntryViewModel: CurrentTimeEntryViewModel) {
    self.currentTimeEntryViewModel = currentTimeEntryViewModel
  }
}
