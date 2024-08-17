import SwiftUI

struct PayPeriodDetails: View {
  var payPeriod: PayPeriod

  init(payPeriod: PayPeriod) {
    self.payPeriod = payPeriod
  }

  var body: some View {
    List(payPeriod.timeEntries.filter { payPeriod.range.contains( $0.start ) }.groupByDay() ) { dailyTimeEntryList in
      PayPeriodSection(timeEntries: dailyTimeEntryList)
    }
    .navigationDestination(for: TimeEntry.self) { timeEntry in
      TimeEntryDetails(timeEntry: timeEntry)
    }
    .navigationTitle("\(Formatting.yearlessDateformatter.string(from: payPeriod.range.lowerBound)) - \(Formatting.yearlessDateformatter.string(from: payPeriod.range.upperBound))")
  }
}
