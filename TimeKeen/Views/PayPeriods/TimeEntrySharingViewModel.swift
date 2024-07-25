import Foundation
import SwiftData

@Observable class TimeEntrySharingViewModel {
  private var context: ModelContext
  var from = Date()
  var to = Date()
  
  init(context: ModelContext) {
    self.context = context
  }
}
