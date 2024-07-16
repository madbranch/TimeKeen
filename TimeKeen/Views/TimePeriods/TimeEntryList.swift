import SwiftUI
import CoreData

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
      .onAppear(perform: self.viewModel.fetchData)
      .navigationTitle("Time Entries")
    }
  }
}
