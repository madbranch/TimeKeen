import SwiftUI
import SwiftData

struct TimeSheetOnTheClockView: View {
    @Environment(\.colorScheme) var colorScheme
    @Query private var timeEntries: [TimeEntry]
    private let clockInDuration: TimeInterval
    private let payPeriod: ClosedRange<Date>
    
    init(payPeriod: ClosedRange<Date>, clockInDuration: TimeInterval) {
        self.clockInDuration = clockInDuration
        self.payPeriod = payPeriod
        _timeEntries = Query(filter: TimeEntry.predicate(start: payPeriod.lowerBound, end: payPeriod.upperBound))
    }
    
    var body: some View {
        let t = timeEntries.reduce(TimeInterval()) { $0 + $1.onTheClock } + max(0, clockInDuration)
        
        if t > 0 {
            HStack {
                Label("Worked **\(Formatting.timeIntervalFormatter.string(from: t) ?? "")** since \(Formatting.yearlessDateformatter.string(from: payPeriod.lowerBound))", systemImage: "stopwatch")
                    .contentTransition(.numericText(value: clockInDuration))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                Image(systemName: "chevron.forward")
                    .foregroundStyle(.tertiary)
                    .font(.system(.callout))
                    .fontWeight(.medium)
                    .padding()
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(colorScheme == .light ? UIColor.systemBackground : UIColor.secondarySystemBackground))
            )
            .shadow(radius: 10)
            .transition(.slide)
        }
    }
}
