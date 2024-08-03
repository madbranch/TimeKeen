import SwiftUI
import SwiftData

@main
struct TimeKeenApp: App {
  let container: ModelContainer
  
  init() {
    do {
      container = try ModelContainer(for: TimeEntry.self, BreakEntry.self)
    } catch {
      fatalError("Failed to create ModelContainer for TimeEntry")
    }
  }
  
  var body: some Scene {
    WindowGroup {
      let userDefaults = SharedData.userDefaults ?? UserDefaults.standard
      let start = userDefaults.object(forKey: "ClockInDate") as? Date
      let breakStart = userDefaults.object(forKey: "BreakStart") as? Date
      let breaks = userDefaults.breaks
      let context = container.mainContext
      let currentTimeEntryViewModel = CurrentTimeEntryViewModel(context: context, clockedInAt: start, startedBreakAt: breakStart, withBreaks: breaks, userDefaults: userDefaults)
      let timeEntrySharingViewModel = TimeEntrySharingViewModel(context: context)
      let payPeriodListViewModel = PayPeriodListViewModel(timeEntrySharingViewModel: timeEntrySharingViewModel, context: context)
      let viewModel = ContentViewModel(currentTimeEntryViewModel: currentTimeEntryViewModel, payPeriodListViewModel: payPeriodListViewModel)
      
      ContentView(viewModel: viewModel)
    }
  }
}
