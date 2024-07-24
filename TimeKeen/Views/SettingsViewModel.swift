import SwiftUI
import SwiftData

@Observable class SettingsViewModel {
  private var context: ModelContext
  
  init(context: ModelContext) {
    self.context = context
  }
  
  func deleteAllEntries() {
    do {
      try context.delete(model: TimeEntry.self)
      try context.delete(model: BreakEntry.self)
    } catch {
      fatalError(error.localizedDescription)
    }
  }
}
