import SwiftUI

@main
struct TimeKeenApp: App {
  let persistenceController = PersistenceController()
  
  var body: some Scene {
    WindowGroup {
      let currentTimeEntryViewModel = CurrentTimeEntryViewModel(context: persistenceController.container.viewContext, start: UserDefaults.standard.object(forKey: "ClockInDate") as? Date)
      let viewModel = ContentViewModel(currentTimeEntryViewModel: currentTimeEntryViewModel)
      
      ContentView(viewModel: viewModel)
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
