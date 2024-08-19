import SwiftUI

struct PayPeriodSettingsSheet: View {
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    NavigationStack {
      PayPeriodSettingsView()
        .background(.background.secondary)
        .navigationTitle("Settings")
        .toolbar {
          ToolbarItem(placement: .confirmationAction) {
            Button("Done", action: dismiss.callAsFunction)
          }
        }
    }
  }
}
