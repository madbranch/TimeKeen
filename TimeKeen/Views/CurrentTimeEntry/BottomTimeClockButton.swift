import SwiftUI

struct BottomHalfCircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height) * 0.4
        let center = CGPoint(x: rect.midX, y: rect.midY + (radius * 0.4))
        path.addArc(center: center, radius: radius, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: true)
        path.closeSubpath()
        return path
    }
}

struct BottomTimeClockButton: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                BottomHalfCircle()
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

#Preview {
    Button {
    } label: {
        Text("Clock In...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
    }
    .buttonStyle(BottomTimeClockButton())
}
