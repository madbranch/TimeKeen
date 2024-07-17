import SwiftUI

struct PayPeriodDetails: View {
  @ObservedObject var viewModel: PayPeriodViewModel
  private let dateFormat: DateFormatter
  private static let durationStyle = Duration.TimeFormatStyle(pattern: .hourMinute)

  init(viewModel: PayPeriodViewModel) {
    self.viewModel = viewModel
    dateFormat = DateFormatter()
    dateFormat.dateStyle = .medium
    dateFormat.timeStyle = .none
  }

  var body: some View {
    List(viewModel.dailyTimeEntryLists) { dailyTimeEntryList in
      Section(header: Text("omg")) {
        ForEach(dailyTimeEntryList.timeEntries) { timeEntry in
          TimeEntryRow(timeEntry: timeEntry)
        }
        .onAppear(perform: dailyTimeEntryList.computeProperties)
      }
    }
    .navigationTitle("\(dateFormat.string(from: viewModel.payPeriodStart)) - \(dateFormat.string(from: viewModel.payPeriodEnd))")
  }
}
