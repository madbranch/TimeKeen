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
  
  private static func getBreaks() -> [BreakItem]? {
    guard let data = UserDefaults.standard.object(forKey: "Breaks") as? Data else {
      return nil
    }
    
    guard let breaks = try? JSONDecoder().decode([BreakItem].self, from: data) else {
      return nil
    }
    
    return breaks
  }
  
  var body: some Scene {
    WindowGroup {
      let start = UserDefaults.standard.object(forKey: "ClockInDate") as? Date
      let breakStart = UserDefaults.standard.object(forKey: "BreakStart") as? Date
      let breaks = TimeKeenApp.getBreaks()
      let context = container.mainContext
      let currentTimeEntryViewModel = CurrentTimeEntryViewModel(context: context, clockedInAt: start, startedBreakAt: breakStart, withBreaks: breaks)
      let timeEntrySharingViewModel = TimeEntrySharingViewModel(context: context)
      let payPeriodListViewModel = PayPeriodListViewModel(timeEntrySharingViewModel: timeEntrySharingViewModel, context: context)
      let viewModel = ContentViewModel(currentTimeEntryViewModel: currentTimeEntryViewModel, payPeriodListViewModel: payPeriodListViewModel)

      ContentView(viewModel: viewModel)
    }
  }
}
