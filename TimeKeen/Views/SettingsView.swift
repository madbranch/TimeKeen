import SwiftUI

struct SettingsView: View {
  @AppStorage("MinuteInterval") var minuteInterval = 15 {
    didSet {
      UIDatePicker.appearance().minuteInterval = minuteInterval
    }
  }
  
  @AppStorage("PayPeriodSchedule") var payPeriodSchedule = PayPeriodSchedule.Weekly
  
  @AppStorage("EndOfLastPayPeriod") var endOfLastPayPeriod = Calendar.current.date(from: DateComponents(year: 2024, month: 07, day: 21))!
  
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
      DatePicker("Period Ends", selection: $endOfLastPayPeriod, displayedComponents: [.date] )
        .datePickerStyle(.compact)
      Button("Reset Settings to Defaults", role: .destructive) {
        UserDefaults.standard.removeObject(forKey: "MinuteInterval")
        UserDefaults.standard.removeObject(forKey: "PayPeriodSchedule")
        UserDefaults.standard.removeObject(forKey: "EndOfLastPayPeriod")
      }
      Button("Delete All Entries", role: .destructive) {
        print("Delete All")
      }
    }
  }
}
