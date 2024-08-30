import SwiftUI

struct PayPeriodDetails: View {
  @State var payPeriod: PayPeriod
  @Environment(\.modelContext) private var context
  @Environment(\.dismiss) private var dismiss

  init(payPeriod: PayPeriod) {
    self.payPeriod = payPeriod
  }
  
  var body: some View {
    List {
      ForEach(payPeriod.timeEntries.filter { payPeriod.range.contains( $0.start ) }.groupByDay()) { timeEntries in
        Section {
          ForEach(timeEntries) { timeEntry in
            NavigationLink(value: timeEntry) {
              TimeEntryRow(timeEntry: timeEntry)
            }
          }
        } header: {
          DailyTimeEntryListSectionHeader(timeEntries: timeEntries)
        }
      }
      .onDelete { offsets in
        for index in offsets {
          context.delete(payPeriod.timeEntries[index])
        }
        payPeriod.timeEntries.remove(atOffsets: offsets)

        if payPeriod.timeEntries.isEmpty {
          dismiss()
        }
      }
    }
    .navigationDestination(for: TimeEntry.self) { timeEntry in
      TimeEntryDetails(timeEntry: timeEntry) { timeEntry in
        payPeriod = PayPeriod(range: payPeriod.range, timeEntries: payPeriod.timeEntries.filter { [timeEntry] in $0 != timeEntry })
      }
    }
    .navigationTitle("\(Formatting.yearlessDateformatter.string(from: payPeriod.range.lowerBound)) - \(Formatting.yearlessDateformatter.string(from: payPeriod.range.upperBound))")
  }
  
  private func onDelete() {
    print("huh")
  }
}
