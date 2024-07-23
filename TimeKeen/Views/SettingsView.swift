import SwiftUI

struct SettingsView: View {
  @AppStorage("MinuteInterval") var minuteInterval = 15 {
    didSet {
      UIDatePicker.appearance().minuteInterval = minuteInterval
    }
  }
  
  @AppStorage("PayPeriodSchedule") var payPeriodSchedule = PayPeriodSchedule.Weekly
  
  var body: some View {
    List {
      Picker("Minute Interval", selection: $minuteInterval) {
        Text("1 minute").tag(1)
        Text("5 minutes").tag(5)
        Text("15 minutes").tag(15)
      }
      Picker("Schedule", selection: $payPeriodSchedule) {
        Text("Weekly").tag(PayPeriodSchedule.Weekly)
        Text("Biweekly").tag(PayPeriodSchedule.Biweekly)
        Text("Monthly").tag(PayPeriodSchedule.Monthly)
        Text("Every Four Weeks").tag(PayPeriodSchedule.EveryFourWeeks)
        Text("1st & 16th").tag(PayPeriodSchedule.FirstAndSixteenth)
      }
      LabeledContent("Period Ends") {
        Text("Every Sunday")
      }
      Button("Reset Settings to Defaults", role: .destructive) {
        minuteInterval = 15
      }
      Button("Delete All Entries", role: .destructive) {
        print("Delete All")
      }
    }
  }
}
