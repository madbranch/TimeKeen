import SwiftUI

struct TimeClockButton: ButtonStyle {
  @Environment(\.isEnabled) var isEnabled
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .background(
        Circle()
          .fill(LinearGradient(gradient: Gradient(colors: [ColorPalette.primary.color, ColorPalette.secondary.color]), startPoint: .top, endPoint: .bottom))
      )
      .font(.system(.largeTitle, design: .rounded))
      .foregroundColor(.white)
      .contentShape(.circle)
      .shadow(radius: 10)
      .opacity(configuration.isPressed ? 0.5 : 1)
      .saturation(isEnabled ? 1 : 0)
  }
}
