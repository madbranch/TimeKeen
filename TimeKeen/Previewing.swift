import SwiftData

class Previewing {
  static var modelContainer: ModelContainer {
    try! ModelContainer(for: TimeEntry.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
  }
}
