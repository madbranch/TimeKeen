import SwiftUI

struct ContentView: View {
  var viewModel: ContentViewModel
  @State private var path: NavigationPath = .init()
  @State private var selectedTab = 0
  @AppStorage(SharedData.Keys.minuteInterval.rawValue, store: SharedData.userDefaults) var minuteInterval = 15
  
  init(viewModel: ContentViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    TabView(selection: $selectedTab) {
      CurrentTimeEntryView(viewModel: viewModel.currentTimeEntryViewModel)
        .tabItem {
          Label("Clock In", systemImage: "clock")
        }
        .tag(0)
      NavigationStack(path: $path) {
        PayPeriodList(viewModel: viewModel.payPeriodListViewModel)
          .navigationTitle("Pay Periods")
      }
      .tabItem {
        Label("Pay Periods", systemImage: "list.bullet")
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
