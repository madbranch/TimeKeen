import SwiftUI

struct SettingsView: View {
  var viewModel: SettingsViewModel
  @AppStorage("PayPeriodSchedule") var payPeriodSchedule = PayPeriodSchedule.Weekly
  @AppStorage("EndOfLastPayPeriod") var endOfLastPayPeriod = Calendar.current.date(from: DateComponents(year: 2024, month: 07, day: 21))!
  @State var isPresentingSettingsResetDialog = false
  @State var isPresentingEntryDeletingDialog = false
  
  init(viewModel: SettingsViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    List {
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
      Button("Reset Settings to Defaults", role: .destructive) {
        isPresentingSettingsResetDialog = true
      }
      .confirmationDialog("Reset Settings", isPresented: $isPresentingSettingsResetDialog, titleVisibility: .visible) {
        Button("Reset Settings", role: .destructive) {
          UserDefaults.standard.removeObject(forKey: "MinuteInterval")
          UserDefaults.standard.removeObject(forKey: "PayPeriodSchedule")
          UserDefaults.standard.removeObject(forKey: "EndOfLastPayPeriod")
        }
        Button("Cancel", role: .cancel) {
          isPresentingSettingsResetDialog = false
        }
      } message: {
        Text("This will reset all application settings to their defaults. No data will be lost")
      }
      Button("Delete All Entries", role: .destructive) {
        isPresentingEntryDeletingDialog = true
      }
      .confirmationDialog("Delete All Entries", isPresented: $isPresentingEntryDeletingDialog, titleVisibility: .visible) {
        Button("Delete All Entries", role: .destructive, action: viewModel.deleteAllEntries )
        Button("Cancel", role: .cancel) {
          isPresentingEntryDeletingDialog = false
        }
      } message: {
        Text("This will delete all log entries.")
      }
    }
  }
}
