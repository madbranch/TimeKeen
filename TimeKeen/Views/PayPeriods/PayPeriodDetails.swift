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

    // App storage values used for the current running clock-in
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
            // Group entries by day
            let grouped = timeEntries.filter { payPeriod.contains($0.start) }.groupByDay()

            // If the clock-in day doesn't exist in grouped days but should be shown, create a synthetic section later
            let clockInDayOnly = Calendar.current.dateOnly(from: clockInDate)
            let hasClockInDayInGroups = grouped.contains { group in
                guard let first = group.first else { return false }
                return Calendar.current.dateOnly(from: first.start) == clockInDayOnly
            }

            // Iterate groups and inject the running entry into its matching day
            ForEach(grouped) { dayEntries in
                Section {
                    if shouldShowCurrentClockedIn && isSameDay(dayEntries.first?.start, clockInDate) {
                        CurrentRunningRow(start: clockInDate, duration: clockInDuration, isOnBreak: clockInState == .clockedInTakingABreak)
                    }

                    ForEach(dayEntries) { timeEntry in
                        NavigationLink(value: timeEntry) {
                            TimeEntryRow(timeEntry: timeEntry)
                        }
                    }
                } header: {
                    DailyTimeEntryListSectionHeader(timeEntries: dayEntries)
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

            // If the running clock-in belongs to a day that has no existing entries, show it as its own day section
            if shouldShowCurrentClockedIn && !hasClockInDayInGroups {
                Section {
                    CurrentRunningRow(start: clockInDate, duration: clockInDuration, isOnBreak: clockInState == .clockedInTakingABreak)
                } header: {
                    Text(clockInDate.formatted(date: .complete, time: .omitted))
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

    private func isSameDay(_ a: Date?, _ b: Date) -> Bool {
        guard let a = a else { return false }
        return Calendar.current.dateOnly(from: a) == Calendar.current.dateOnly(from: b)
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

private struct CurrentRunningRow: View {
    let start: Date
    let duration: TimeInterval
    let isOnBreak: Bool

    var body: some View {
        HStack {
            Text("\(Formatting.startEndFormatter.string(from: start)) - Now")
            Spacer()
            Text(Formatting.timeIntervalFormatter.string(from: duration) ?? "")
                .foregroundStyle(isOnBreak ? .secondary : .secondary)
        }
        .accessibilityIdentifier("CurrentClockedInRow")
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
