import SwiftUI

struct PayPeriodRow: View {
    private let payPeriod: PayPeriod
    
    init(payPeriod: PayPeriod) {
        self.payPeriod = payPeriod
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(Formatting.yearlessDateformatter.string(from: payPeriod.range.lowerBound)) - \(Formatting.yearlessDateformatter.string(from: payPeriod.range.upperBound))")
                    .font(.headline)
                Text(payPeriod.timeEntries.count == 1 ? "1 entry" : "\(payPeriod.timeEntries.count) entries")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(Formatting.timeIntervalFormatter.string(from: payPeriod.timeEntries.reduce(TimeInterval()) { $0 + $1.onTheClock }) ?? "")
                .foregroundStyle(.secondary)
        }
    }
}
