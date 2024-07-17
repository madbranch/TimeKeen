import SwiftUI

struct ContentView: View {
  @ObservedObject var viewModel: ContentViewModel
  
  init(viewModel: ContentViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    NavigationView {
      CurrentTimeEntryView(viewModel: viewModel.currentTimeEntryViewModel)
        .navigationTitle("Time Keen")
        .toolbar {
          ToolbarItem(placement: .bottomBar) {
            Button {
            } label: {
              Image(systemName: "gear")
            }
          }
          ToolbarItem(placement: .bottomBar) {
            NavigationLink {
              NavigationView {
                PayPeriodList(viewModel: viewModel.payPeriodListViewModel)
              }
              .navigationTitle("Pay Periods")
            } label: {
              Image(systemName: "list.bullet")
            }
          }
        }
    }
    .padding()
    .onAppear {
      UIDatePicker.appearance().minuteInterval = 15
    }
  }
}
