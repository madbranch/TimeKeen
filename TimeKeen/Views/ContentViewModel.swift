import Foundation

final class ContentViewModel: ObservableObject {
  @Published var currentTimeEntryViewModel: CurrentTimeEntryViewModel
  
  init(currentTimeEntryViewModel: CurrentTimeEntryViewModel) {
    self.currentTimeEntryViewModel = currentTimeEntryViewModel
  }
}
