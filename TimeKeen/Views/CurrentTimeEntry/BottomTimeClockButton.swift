import SwiftUI

struct BottomHalfCircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height) * 0.5
        let center = CGPoint(x: rect.midX, y: rect.minY)
        path.addArc(center: center, radius: radius, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
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
                    .fill(LinearGradient(gradient: Gradient(colors: [ColorPalette.primary.color, ColorPalette.secondary.color]), startPoint: UnitPoint(x: 0.5, y: -0.5), endPoint: .center))
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
