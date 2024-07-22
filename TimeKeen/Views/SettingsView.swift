import SwiftUI

struct SettingsView: View {
  @AppStorage("MinuteInterval") var minuteInterval = 15 {
    didSet {
      UIDatePicker.appearance().minuteInterval = minuteInterval
    }
  }
  
  var body: some View {
    List {
      Picker("Minute Interval", selection: $minuteInterval) {
        Text("1").tag(1)
        Text("5").tag(5)
        Text("15").tag(15)
      }
      LabeledContent("Schedule") {
        Text("Weekly")
      }
      LabeledContent("Period Ends") {
        Text("Every Sunday")
      }
      Button("Reset Settings to Defaults", role: .destructive) {
        print("Reset Settings")
      }
      Button("Delete All Entries", role: .destructive) {
        print("Delete All")
      }
    }
  }
}
