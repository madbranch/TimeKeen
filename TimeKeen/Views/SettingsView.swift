import SwiftUI

struct SettingsView: View {
  var body: some View {
    List {
      LabeledContent("Minute Interval") {
        Text("00:15")
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
