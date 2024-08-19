import SwiftUI

struct PayPeriodSettingsView: View {
  
  @AppStorage(SharedData.Keys.minuteInterval.rawValue, store: SharedData.userDefaults) var minuteInterval = 15 {
    didSet {
      UIDatePicker.appearance().minuteInterval = minuteInterval
    }
  }
  @AppStorage(SharedData.Keys.payPeriodSchedule.rawValue, store: SharedData.userDefaults) var payPeriodSchedule = PayPeriodSchedule.Weekly
  @AppStorage(SharedData.Keys.endOfLastPayPeriod.rawValue, store: SharedData.userDefaults) var endOfLastPayPeriod = Calendar.current.date(from: DateComponents(year: 2024, month: 07, day: 21))!
  
  var body: some View {
    List {
      Section {
        Picker("Minute Interval", selection: $minuteInterval) {
          Text("1 minute").tag(1)
          Text("5 minutes").tag(5)
          Text("10 minutes").tag(10)
          Text("15 minutes").tag(15)
        }
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
      } footer: {
        Text("Pay period scheduling lets you define how to group clocked-in time.")
      }
      Section("Tip Jar") {
        TipStoreView()
      }
    }
  }
}
