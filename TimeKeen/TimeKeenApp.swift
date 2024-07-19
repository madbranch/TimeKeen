import SwiftUI
import SwiftData

@main
struct TimeKeenApp: App {
  let container: ModelContainer
  
  init() {
    do {
      container = try ModelContainer(for: TimeEntry.self)
    } catch {
      fatalError("Failed to create ModelContainer for TimeEntry")
    }
  }
  
  var body: some Scene {
    WindowGroup {
      let start = UserDefaults.standard.object(forKey: "ClockInDate") as? Date
      let context = container.mainContext
      let currentTimeEntryViewModel = CurrentTimeEntryViewModel(context: context, clockedInAt: start)
      let payPeriodListViewModel = PayPeriodListViewModel(context: context)
      let viewModel = ContentViewModel(currentTimeEntryViewModel: currentTimeEntryViewModel, payPeriodListViewModel: payPeriodListViewModel)

      ContentView(viewModel: viewModel)
    }
  }
}
