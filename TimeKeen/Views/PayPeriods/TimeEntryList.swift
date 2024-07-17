import SwiftUI

struct TimeEntryList : View {
  @ObservedObject var viewModel: TimeEntryListViewModel
  
  init(viewModel: TimeEntryListViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    NavigationView {
      List(viewModel.timeEntries) { timeEntry in
        TimeEntryRow(timeEntry: timeEntry)
      }
      .onAppear(perform: self.viewModel.computeProperties)
      .navigationTitle("Time Entries")
    }
  }
}
