import Foundation

final class ContentViewModel: ObservableObject {
  @Published var currentTimeEntryViewModel: CurrentTimeEntryViewModel
  @Published var timePeriodsViewModel: TimePeriodsViewModel
  
  init(currentTimeEntryViewModel: CurrentTimeEntryViewModel, timePeriodsViewModel: TimePeriodsViewModel) {
    self.currentTimeEntryViewModel = currentTimeEntryViewModel
    self.timePeriodsViewModel = timePeriodsViewModel
  }
}
