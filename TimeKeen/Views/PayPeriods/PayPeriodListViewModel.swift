import Foundation
import SwiftUI
import SwiftData

@Observable class PayPeriodListViewModel {
  var timeEntrySharingViewModel: TimeEntrySharingViewModel
  
  init(timeEntrySharingViewModel: TimeEntrySharingViewModel, context: ModelContext) {
    self.timeEntrySharingViewModel = timeEntrySharingViewModel
  }
}
