import SwiftUI
import SwiftData

struct TimeSheetOnTheClockView: View {
    @Environment(\.colorScheme) var colorScheme
    @Query var timeEntries: [TimeEntry]
    @Binding var clockInDuration: TimeInterval
    @Binding var payPeriod: ClosedRange<Date>
    
    init(payPeriod: Binding<ClosedRange<Date>>, clockInDuration: Binding<TimeInterval>) {
        _clockInDuration = clockInDuration
        _payPeriod = payPeriod
        _timeEntries = Query(filter: #Predicate<TimeEntry> { [payPeriod = self.payPeriod] timeEntry in
            return timeEntry.start >= payPeriod.lowerBound && timeEntry.start <= payPeriod.upperBound
        })
    }
    
    var body: some View {
        let t = timeEntries.reduce(TimeInterval()) { $0 + $1.onTheClock } + max(0, clockInDuration)
        
        if t > 0 {
            Label("Worked **\(Formatting.timeIntervalFormatter.string(from: t) ?? "")** since \(Formatting.yearlessDateformatter.string(from: payPeriod.lowerBound))", systemImage: "stopwatch")
                .contentTransition(.numericText(value: clockInDuration))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(colorScheme == .light ? UIColor.systemBackground : UIColor.secondarySystemBackground))
                )
                .shadow(radius: 10)
                .transition(.slide)
        }
    }
}
