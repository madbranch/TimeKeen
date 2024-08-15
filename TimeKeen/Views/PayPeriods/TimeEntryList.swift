import SwiftUI

struct TimeEntryList: View {
  var viewModel: TimeEntryListViewModel
  
  @Environment(\.dismiss) private var dismiss

  init(viewModel: TimeEntryListViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    ForEach(viewModel.timeEntries) { timeEntry in
      NavigationLink(value: timeEntry) {
        TimeEntryRow(timeEntry: timeEntry)
      }
    }
    .onDelete { offsets in
      viewModel.deleteTimeEntries(at: offsets)
      
      if viewModel.timeEntries.isEmpty {
        dismiss()
      }
    }
    .onAppear(perform: viewModel.computeProperties)
  }
}
