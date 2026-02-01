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

    // Minute interval and notes (used by clock out picker)
    @AppStorage(SharedData.Keys.minuteInterval.rawValue, store: SharedData.userDefaults) var minuteInterval = 15 {
        didSet {
            UIDatePicker.appearance().minuteInterval = minuteInterval
        }
    }
    @AppStorage(SharedData.Keys.notes.rawValue, store: SharedData.userDefaults) private var notes = ""

    // Clock-out sheet state
    @State private var isClockingOut = false
    @State private var clockOutDate = Date.now
    @State private var minClockOutDate = Date.now

    @State private var clockInDuration: TimeInterval = .zero
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(for payPeriod: ClosedRange<Date>) {
        self.payPeriod = payPeriod
        _timeEntries = Query(filter: TimeEntry.predicate(start: payPeriod.lowerBound, end: payPeriod.upperBound), sort: \TimeEntry.start, order: .reverse)
    }

    var body: some View {
        List {
            // Group entries by day
            // Build grouped days from the query, then reverse to show most-recent days first.
            let grouped = timeEntries.filter { payPeriod.contains($0.start) }
                .groupByDay()

            // Determine if the clock-in day already exists in the grouped days
            let clockInDayOnly = Calendar.current.dateOnly(from: clockInDate)
            let hasClockInDayInGroups = grouped.contains { $0.id == clockInDayOnly }
            
            // If the running clock-in belongs to a day that has no existing entries, show it as its own day section and include duration in its header
            if shouldShowCurrentClockedIn && !hasClockInDayInGroups {
                Section {
                    Button {
                        if startClockingOut() {
                            isClockingOut = true
                        }
                    } label: {
                        CurrentRunningRow(start: clockInDate, duration: clockInDuration, isOnBreak: clockInState == .clockedInTakingABreak)
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                } header: {
                    HStack {
                        Text(clockInDate.formatted(date: .complete, time: .omitted))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(Formatting.timeIntervalFormatter.string(from: clockInDuration) ?? "")
                    }
                }
            }

            // Iterate groups and inject the running entry into its matching day (and include its duration in the header totals)
            ForEach(grouped) { dayGroup in
                let isClockInDay = dayGroup.id == clockInDayOnly
                let extraForHeader: TimeInterval = (shouldShowCurrentClockedIn && isClockInDay) ? clockInDuration : .zero

                Section {
                    // If this is the clock-in day and we're currently clocked in, show a running row at the top of the day's section
                    if shouldShowCurrentClockedIn && isClockInDay {
                        Button {
                            if startClockingOut() {
                                isClockingOut = true
                            }
                        } label: {
                            CurrentRunningRow(start: clockInDate, duration: clockInDuration, isOnBreak: clockInState == .clockedInTakingABreak)
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                    }

                    ForEach(dayGroup.entries) { timeEntry in
                        NavigationLink(value: timeEntry) {
                            TimeEntryRow(timeEntry: timeEntry)
                        }
                    }
                    .onDelete { offsets in
                        for index in offsets {
                            context.delete(dayGroup.entries[index])
                        }
                        WidgetCenter.shared.reloadTimelines(ofKind: "TimeKeenWidgetExtension")
                    }
                } header: {
                    DailyTimeEntryListSectionHeader(timeEntries: dayGroup.entries, extraDuration: extraForHeader)
                }
            }
        }
        .navigationTitle("\(Formatting.yearlessDateformatter.string(from: payPeriod.lowerBound)) - \(Formatting.yearlessDateformatter.string(from: payPeriod.upperBound))")
        .onAppear { updateClockInDuration(input: dateProvider.now) }
        .onReceive(timer) { input in updateClockInDuration(input: input) }
        // Clock-out sheet (same UI as in CurrentTimeEntryView)
        .sheet(isPresented: $isClockingOut) { [clockOutDate, minClockOutDate, minuteInterval] in
            NavigationStack {
                IntervalDatePicker(selection: $clockOutDate, minuteInterval: minuteInterval, in: minClockOutDate..., displayedComponents: [.date, .hourAndMinute], style: .wheels)
                    .accessibilityIdentifier("ClockOutDatePicker")
                    .navigationTitle("Clock Out")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Stop") {
                                clockOut(at: clockOutDate, notes: notes)
                                isClockingOut = false
                            }
                            .accessibilityIdentifier("ClockOutStopButton")
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel", role: .cancel) {
                                isClockingOut = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium])
        }
    }

    private var shouldShowCurrentClockedIn: Bool {
        return payPeriod.contains(clockInDate) && clockInState != .clockedOut
    }

    private func updateClockInDuration(input: Date) {
        switch clockInState {
        case .clockedOut:
            clockInDuration = .zero
        case .clockedInWorking:
            let onBreak = breaks.reduce(TimeInterval()) { $0 + $1.interval }
            let sinceClockIn = clockInDate.distance(to: dateProvider.now)
            clockInDuration = max(.zero, sinceClockIn - onBreak)
        case .clockedInTakingABreak:
            let onBreak = breaks.reduce(TimeInterval()) { $0 + $1.interval }
            let sinceClockIn = clockInDate.distance(to: dateProvider.now)
            let sinceBreakStart = max(TimeInterval(), breakStart.distance(to: dateProvider.now))
            clockInDuration = max(.zero, sinceClockIn - onBreak - sinceBreakStart)
        }
    }

    private func getRoundedNow() -> Date {
        return Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: dateProvider.now)
    }

    private func startClockingOut() -> Bool {
        guard clockInState == .clockedInWorking else {
            return false
        }

        guard let newDate = Calendar.current.date(byAdding: .minute, value: minuteInterval, to: clockInDate) else {
            return false
        }

        minClockOutDate = Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: newDate)
        clockOutDate = max(minClockOutDate, Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: dateProvider.now))
        return true
    }

    private func clockOut(at end: Date, notes: String) {
        guard clockInState == .clockedInWorking && clockInDate != end else {
            return
        }

        let timeEntry = TimeEntry(from: clockInDate, to: end, notes: notes)
        timeEntry.breaks.append(contentsOf: breaks)
        context.insert(timeEntry)
        clockInState = .clockedOut
        updateClockInDuration(input: dateProvider.now)
        reloadWidget()
    }

    private func reloadWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: "TimeKeenWidgetExtension")
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
                .foregroundStyle(isOnBreak ? .tertiary : .secondary)
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
