import SwiftUI
import StoreKit

struct TipPickerSheet: View {
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    NavigationStack {
      StoreView(ids: ["com.timekeen.TimeKeen.lovely", "com.timekeen.TimeKeen.sensational", "com.timekeen.TimeKeen.silly"])
        .storeButton(.hidden, for: .cancellation)
        .background(.background.secondary)
        .navigationTitle("Tip Jar")
        .toolbar {
          ToolbarItem(placement: .confirmationAction) {
            Button("Done", action: dismiss.callAsFunction)
          }
        }
    }
  }
}
