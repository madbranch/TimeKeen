import SwiftUI

struct ContentView: View {
  var viewModel: ContentViewModel
  @State private var path: NavigationPath = .init()
  @State private var selectedTab = 0
  
  init(viewModel: ContentViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    TabView(selection: $selectedTab) {
      CurrentTimeEntryView(viewModel: viewModel.currentTimeEntryViewModel)
        .tabItem {
          Label("Clock-In", systemImage: "clock")
        }
        .tag(0)
      Text("omg settings")
        .tabItem {
          Label("Settings", systemImage: "gear")
        }
        .tag(1)
      NavigationStack(path: $path) {
        PayPeriodList(viewModel: viewModel.payPeriodListViewModel)
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
