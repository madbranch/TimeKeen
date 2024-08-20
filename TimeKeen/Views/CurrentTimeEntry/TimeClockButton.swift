import SwiftUI

struct TimeClockButton: ButtonStyle {
  @Environment(\.isEnabled) var isEnabled
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .background(
        Circle()
          .fill(LinearGradient(gradient: Gradient(colors: [Color(red: 31/255, green: 126/255, blue: 161/255), Color(red: 111/255, green: 247/255, blue: 232/255)]), startPoint: .top, endPoint: .bottom))
      )
      .foregroundColor(.white)
      .contentShape(.circle)
      .shadow(radius: 10)
      .opacity(configuration.isPressed ? 0.5 : 1)
      .saturation(isEnabled ? 1 : 0)
  }
}
