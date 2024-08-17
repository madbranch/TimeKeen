import SwiftUI

struct PayPeriodSettingsSheet: View {
  @Environment(\.dismiss) private var dismiss
  @AppStorage(SharedData.Keys.payPeriodSchedule.rawValue, store: SharedData.userDefaults) var payPeriodSchedule = PayPeriodSchedule.Weekly
  @AppStorage(SharedData.Keys.endOfLastPayPeriod.rawValue, store: SharedData.userDefaults) var endOfLastPayPeriod = Calendar.current.date(from: DateComponents(year: 2024, month: 07, day: 21))!
  
  var body: some View {
    VStack {
      Text("Pay Periods")
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .center)
        .overlay(alignment: .trailing) {
          Button("OK") {
            dismiss()
          }
        }
        .padding([.bottom])
      Text("Choose how you want your time entries to be grouped.")
        .font(.subheadline)
      Picker("Schedule", selection: $payPeriodSchedule) {
        Text("Weekly").tag(PayPeriodSchedule.Weekly)
        Text("Biweekly").tag(PayPeriodSchedule.Biweekly)
        Text("Monthly").tag(PayPeriodSchedule.Monthly)
        Text("Every Four Weeks").tag(PayPeriodSchedule.EveryFourWeeks)
        Text("1st & 16th").tag(PayPeriodSchedule.FirstAndSixteenth)
      }
      if payPeriodSchedule == .FirstAndSixteenth {
        LabeledContent("Period Ends") {
          Text("Twice Monthly")
        }
      } else {
        DatePicker("Period Ends", selection: $endOfLastPayPeriod, displayedComponents: [.date] )
          .datePickerStyle(.compact)
      }
      Spacer()
    }
    .padding()
    .presentationDetents([.medium])
  }
}
