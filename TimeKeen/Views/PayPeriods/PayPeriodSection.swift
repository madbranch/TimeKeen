import SwiftUI

struct PayPeriodSection: View {
  @ObservedObject var viewModel: TimeEntryListViewModel
  
  init(viewModel: TimeEntryListViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    Section(content: { TimeEntryList(viewModel: viewModel) },
            header: { DailyTimeEntryListSectionHeader(viewModel: viewModel) })
  }
}
