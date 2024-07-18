import SwiftUI

struct ContentView: View {
  @ObservedObject var viewModel: ContentViewModel
  
  init(viewModel: ContentViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    TabView {
      CurrentTimeEntryView(viewModel: viewModel.currentTimeEntryViewModel)
        .tabItem {
          Label("Clock-In", systemImage: "clock")
        }
      Text("omg settings")
        .tabItem {
          Label("Settings", systemImage: "gear")
        }
      NavigationStack {
        PayPeriodList(viewModel: viewModel.payPeriodListViewModel)
      }
      .tabItem {
        Label("Pay Periods", systemImage: "list.bullet")
      }
    }
    .onAppear {
      UIDatePicker.appearance().minuteInterval = 15
    }
  }
}
