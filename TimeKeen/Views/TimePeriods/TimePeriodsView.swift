import SwiftUI
import CoreData

struct TimePeriodsView : View {
  @ObservedObject var viewModel: TimePeriodsViewModel
  
  init(viewModel: TimePeriodsViewModel) {
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
