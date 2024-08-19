import SwiftUI

struct ContentView: View {
  var quickActionProvider: QuickActionProvider
  @State private var path: NavigationPath = .init()
  @State private var selectedTab = 0
  @AppStorage(SharedData.Keys.minuteInterval.rawValue, store: SharedData.userDefaults) var minuteInterval = 15
  
  init(quickActionProvider: QuickActionProvider) {
    self.quickActionProvider = quickActionProvider
  }
  
  var body: some View {
    TabView(selection: $selectedTab) {
      CurrentTimeEntryView(quickActionProvider: quickActionProvider)
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
}
