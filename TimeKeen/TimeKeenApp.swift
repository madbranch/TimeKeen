import SwiftUI

@main
struct TimeKeenApp: App {
  let persistenceController = PersistenceController()
  
  var body: some Scene {
    WindowGroup {
      let context = persistenceController.container.viewContext
      let start = UserDefaults.standard.object(forKey: "ClockInDate") as? Date
      let currentTimeEntryViewModel = CurrentTimeEntryViewModel(context: context, start: start)
      let viewModel = ContentViewModel(currentTimeEntryViewModel: currentTimeEntryViewModel)
      
      ContentView(viewModel: viewModel)
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
