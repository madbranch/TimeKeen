import SwiftUI

struct ContentView: View {
  var viewModel: ContentViewModel
  @State private var path: NavigationPath = .init()
  @State private var selectedTab = 1
  
  init(viewModel: ContentViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    TabView(selection: $selectedTab) {
      NavigationStack {
        SettingsView(viewModel: viewModel.settingsViewModel)
          .navigationTitle("Settings")
      }
      .tabItem {
        Label("Settings", systemImage: "gear")
      }
      .tag(0)
      CurrentTimeEntryView(viewModel: viewModel.currentTimeEntryViewModel)
        .tabItem {
          Label("Clock-In", systemImage: "clock")
        }
        .tag(1)
      NavigationStack(path: $path) {
        PayPeriodList(viewModel: viewModel.payPeriodListViewModel)
          .navigationTitle("Pay Periods")
      }
      .tabItem {
        Label("Pay Periods", systemImage: "list.bullet")
      }
      .tag(2)
    }
    .onChange(of: selectedTab) { oldValue, newValue in
      if oldValue == 2 {
        path = .init()
      }
    }
    .onAppear {
      UIDatePicker.appearance().minuteInterval = UserDefaults.standard.minuteInterval
    }
  }
}
