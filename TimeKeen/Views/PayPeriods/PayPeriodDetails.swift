import Foundation
import SwiftUI
import SwiftData
import WidgetKit

struct PayPeriodDetails: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dateProvider) private var dateProvider
    @Query var timeEntries: [TimeEntry]
    private let payPeriod: ClosedRange<Date>

    // Show current running clock-in if present
    @AppStorage(SharedData.Keys.clockInState.rawValue, store: SharedData.userDefaults) private var clockInState = ClockInState.clockedOut
    @AppStorage(SharedData.Keys.clockInDate.rawValue, store: SharedData.userDefaults) private var clockInDate = Date.now
    @AppStorage(SharedData.Keys.breakStart.rawValue, store: SharedData.userDefaults) private var breakStart = Date.now
    @AppStorage(SharedData.Keys.breaks.rawValue, store: SharedData.userDefaults) private var breaks = [BreakEntry]()

    @State private var clockInDuration: TimeInterval = .zero
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(for payPeriod: ClosedRange<Date>) {
        self.payPeriod = payPeriod
        _timeEntries = Query(filter: TimeEntry.predicate(start: payPeriod.lowerBound, end: payPeriod.upperBound), sort: \TimeEntry.start, order: .reverse)
    }

    var body: some View {
        List {
            // If the current pay period includes now and the user is clocked in, show a running row at the top
            if shouldShowCurrentClockedIn {
                Section {
                    HStack {
                        Text("\(Formatting.startEndFormatter.string(from: clockInDate)) - Now")
                        Spacer()
                        Text(Formatting.timeIntervalFormatter.string(from: clockInDuration) ?? "")
                            .foregroundStyle(clockInState == .clockedInTakingABreak ? .secondary : .secondary)
                    }
                    .accessibilityIdentifier("CurrentClockedInRow")
                } header: {
                    Text("Now")
                }
            }

            ForEach(timeEntries.filter { payPeriod.contains( $0.start ) }.groupByDay()) { timeEntries in
                Section {
                    ForEach(timeEntries) { timeEntry in
                        NavigationLink(value: timeEntry) {
                            TimeEntryRow(timeEntry: timeEntry)
                        }
                    }
                } header: {
                    DailyTimeEntryListSectionHeader(timeEntries: timeEntries)
                }
            }
            .onDelete { offsets in
                for index in offsets {
                    context.delete(timeEntries[index])
                }

                _timeEntries.update()
                WidgetCenter.shared.reloadTimelines(ofKind: "TimeKeenWidgetExtension")

                if timeEntries.isEmpty {
                    dismiss()
                }
            }
        }
        .navigationTitle("\(Formatting.yearlessDateformatter.string(from: payPeriod.lowerBound)) - \(Formatting.yearlessDateformatter.string(from: payPeriod.upperBound))")
        .onAppear { updateClockInDuration(input: dateProvider.now) }
        .onReceive(timer) { input in updateClockInDuration(input: input) }
    }

    private var shouldShowCurrentClockedIn: Bool {
        return payPeriod.contains(dateProvider.now) && clockInState != .clockedOut
    }

    private func updateClockInDuration(input: Date) {
        switch clockInState {
        case .clockedOut:
            clockInDuration = .zero
        case .clockedInWorking:
            let onBreak = breaks.reduce(TimeInterval()) { $0 + $1.interval }
            let sinceClockIn = clockInDate.distance(to: dateProvider.now)
            clockInDuration = sinceClockIn - onBreak
        case .clockedInTakingABreak:
            let onBreak = breaks.reduce(TimeInterval()) { $0 + $1.interval }
            let sinceClockIn = clockInDate.distance(to: dateProvider.now)
            let sinceBreakStart = max(TimeInterval(), breakStart.distance(to: dateProvider.now))
            clockInDuration = sinceClockIn - onBreak - sinceBreakStart
        }
    }
}

#Preview {
    let container = Previewing.modelContainer
    for timeEntry in Previewing.someTimeEntries {
        container.mainContext.insert(timeEntry)
    }
    let calendar = Calendar.current
    let from = calendar.date(from: DateComponents(year: 2024, month: 9, day: 5)) ?? Date.now
    let to = calendar.date(from: DateComponents(year: 2024, month: 9, day: 12)) ?? Date.now

    return PayPeriodDetails(for: from...to)
        .modelContainer(container)
}
