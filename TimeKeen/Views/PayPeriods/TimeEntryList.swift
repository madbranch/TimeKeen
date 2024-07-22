import SwiftUI

struct TimeEntryList: View {
  var viewModel: TimeEntryListViewModel

  init(viewModel: TimeEntryListViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    ForEach(viewModel.timeEntries) { timeEntry in
      NavigationLink(value: timeEntry) {
        TimeEntryRow(viewModel: timeEntry)
      }
    }
    .onDelete(perform: viewModel.deleteTimeEntries)
    .onAppear(perform: viewModel.computeProperties)
  }
}
