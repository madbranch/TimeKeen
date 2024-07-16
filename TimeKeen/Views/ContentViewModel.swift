import Foundation

final class ContentViewModel: ObservableObject {
  @Published var currentTimeEntryViewModel: CurrentTimeEntryViewModel
  @Published var timeEntryListViewModel: TimeEntryListViewModel
  
  init(currentTimeEntryViewModel: CurrentTimeEntryViewModel, timeEntryListViewModel: TimeEntryListViewModel) {
    self.currentTimeEntryViewModel = currentTimeEntryViewModel
    self.timeEntryListViewModel = timeEntryListViewModel
  }
}
