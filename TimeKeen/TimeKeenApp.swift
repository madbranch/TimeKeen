import SwiftUI

@main
struct TimeKeenApp: App {
  let persistenceController = PersistenceController()
  
  var body: some Scene {
    WindowGroup {
      CurrentTimeEntryView(viewModel: CurrentTimeEntryViewModel(context: persistenceController.container.viewContext))
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
