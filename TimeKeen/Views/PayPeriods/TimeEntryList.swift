import SwiftUI

struct TimeEntryList: View {
  @ObservedObject var viewModel: TimeEntryListViewModel
  
  init(viewModel: TimeEntryListViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    ForEach(viewModel.timeEntries) { timeEntry in
      TimeEntryRow(timeEntry: timeEntry)
    }
    .onDelete(perform: viewModel.deleteTimeEntries)
    .onAppear(perform: viewModel.computeProperties)
  }
}
