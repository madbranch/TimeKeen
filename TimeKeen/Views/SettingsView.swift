import SwiftUI

struct SettingsView: View {
  var body: some View {
    List {
      Section("Pay Periods") {
        LabeledContent("Schedule") {
          Text("Weekly")
        }
        LabeledContent("Period Ends") {
          Text("Every Sunday")
        }
      }
    }
  }
}
