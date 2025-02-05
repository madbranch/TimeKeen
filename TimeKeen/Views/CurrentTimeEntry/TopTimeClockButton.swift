import SwiftUI

struct TopHalfCircle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height) * 0.5
        let center = CGPoint(x: rect.midX, y: rect.maxY)
        path.addArc(center: center, radius: radius, startAngle: .degrees(0), endAngle: .degrees(180), clockwise: true)
        path.closeSubpath()
        return path
    }
}

struct TopTimeClockButton: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                TopHalfCircle()
                    .fill(LinearGradient(gradient: Gradient(colors: [ColorPalette.primary.color, ColorPalette.secondary.color]), startPoint: .center, endPoint: UnitPoint(x: 0.5, y: 1.5)))
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
    .buttonStyle(TopTimeClockButton())
}
