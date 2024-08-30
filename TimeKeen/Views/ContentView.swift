import SwiftUI
import SwiftData

struct ContentView: View {
  var quickActionProvider: QuickActionProvider
  @State private var path: NavigationPath = .init()
  @State private var selectedTab = 0
  @AppStorage(SharedData.Keys.minuteInterval.rawValue, store: SharedData.userDefaults) var minuteInterval = 15
  @Environment(\.modelContext) private var context
  
  init(quickActionProvider: QuickActionProvider) {
    self.quickActionProvider = quickActionProvider
  }
  
  var body: some View {
    TabView(selection: $selectedTab) {
      CurrentTimeEntryView(quickActionProvider: quickActionProvider, navigate: navigate)
        .tabItem {
          Label("Time Clock", systemImage: "stopwatch")
        }
        .tag(0)
      NavigationStack(path: $path) {
        PayPeriodList()
          .navigationTitle("Time Sheets")
      }
      .tabItem {
        Label("Time Sheets", systemImage: "list.bullet.rectangle")
      }
      .tag(1)
    }
    .onChange(of: selectedTab) { oldValue, newValue in
      if oldValue == 1 {
        path = .init()
      }
    }
    .onAppear {
      UIDatePicker.appearance().minuteInterval = minuteInterval
    }
  }
  
  func navigate(to range: ClosedRange<Date>) {
    let fetchDescriptor = FetchDescriptor<TimeEntry>(predicate: #Predicate { [range = range] timeEntry in
      return timeEntry.start >= range.lowerBound && timeEntry.start <= range.upperBound
    })
    
    do {
      let timeEntries = try context.fetch(fetchDescriptor)
      let payPeriod = PayPeriod(range: range, timeEntries: timeEntries)
      selectedTab = 1
      path = .init()
      path.append(payPeriod)
    } catch {
      selectedTab = 0
      path = .init()
    }
  }
}
