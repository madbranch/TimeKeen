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

    @State private var timeClockManager = TimeClockManager()

    // Clock-out sheet state
    @State private var isClockingOut = false

    // End break sheet state
    @State private var isEndingBreak = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(for payPeriod: ClosedRange<Date>) {
        self.payPeriod = payPeriod
        _timeEntries = Query(filter: TimeEntry.predicate(start: payPeriod.lowerBound, end: payPeriod.upperBound), sort: \TimeEntry.start, order: .reverse)
    }

    var body: some View {
        List {
            // Group entries by day
            // Build grouped days from the query, which is already sorted to show most-recent days first.
            let grouped = timeEntries.filter { payPeriod.contains($0.start) }
                .groupByDay()

            // Determine if the clock-in day already exists in the grouped days
            let clockInDayOnly = Calendar.current.dateOnly(from: timeClockManager.clockInDate)
            let hasClockInDayInGroups = grouped.contains { $0.id == clockInDayOnly }
            
            // If the running clock-in belongs to a day that has no existing entries, show it as its own day section and include duration in its header
            if shouldShowCurrentClockedIn && !hasClockInDayInGroups {
                Section {
                    Button {
                        if timeClockManager.clockInState == .clockedInTakingABreak {
                            if timeClockManager.startEndingBreak() {
                                isEndingBreak = true
                            }
                        } else if timeClockManager.startClockingOut() {
                            isClockingOut = true
                        }
                    } label: {
                        CurrentRunningRow(start: timeClockManager.clockInDate, duration: timeClockManager.clockInDuration, isOnBreak: timeClockManager.clockInState == .clockedInTakingABreak)
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                } header: {
                    HStack {
                        Text(timeClockManager.clockInDate.formatted(date: .complete, time: .omitted))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(Formatting.timeIntervalFormatter.string(from: timeClockManager.clockInDuration) ?? "")
                    }
                }
            }

            // Iterate groups and inject the running entry into its matching day (and include its duration in the header totals)
            ForEach(grouped) { dayGroup in
                let isClockInDay = dayGroup.id == clockInDayOnly
                let extraForHeader: TimeInterval = (shouldShowCurrentClockedIn && isClockInDay) ? timeClockManager.clockInDuration : .zero

                Section {
                    // If this is the clock-in day and we're currently clocked in, show a running row at the top of the day's section
                    if shouldShowCurrentClockedIn && isClockInDay {
                        Button {
                            if timeClockManager.clockInState == .clockedInTakingABreak {
                                if timeClockManager.startEndingBreak() {
                                    isEndingBreak = true
                                }
                            } else if timeClockManager.startClockingOut() {
                                isClockingOut = true
                            }
                        } label: {
                            CurrentRunningRow(start: timeClockManager.clockInDate, duration: timeClockManager.clockInDuration, isOnBreak: timeClockManager.clockInState == .clockedInTakingABreak)
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
        .onAppear {
            timeClockManager.dateProvider = dateProvider
            timeClockManager.modelContextInsert = { context.insert($0) }
            timeClockManager.updateClockInDuration()
        }
        .onReceive(timer) { _ in
            timeClockManager.updateClockInDuration()
        }
        // Clock-out sheet (same UI as in CurrentTimeEntryView)
        .sheet(isPresented: $isClockingOut) { [minClockOutDate = timeClockManager.minClockOutDate, minuteInterval = timeClockManager.minuteInterval] in
            NavigationStack {
                IntervalDatePicker(selection: $timeClockManager.clockOutDate, minuteInterval: minuteInterval, in: minClockOutDate..., displayedComponents: [.date, .hourAndMinute], style: .wheels)
                    .accessibilityIdentifier("ClockOutDatePicker")
                    .navigationTitle("Clock Out")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Stop") {
                                timeClockManager.clockOut(at: timeClockManager.clockOutDate, notes: timeClockManager.notes)
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
        .sheet(isPresented: $isEndingBreak) { [minBreakEndDate = timeClockManager.minBreakEndDate, minuteInterval = timeClockManager.minuteInterval] in
            NavigationStack {
                IntervalDatePicker(selection: $timeClockManager.breakEnd, minuteInterval: minuteInterval, in: minBreakEndDate..., displayedComponents: [.date, .hourAndMinute], style: .wheels)
                    .accessibilityIdentifier("EndBreakDatePicker")
                    .navigationTitle("Go back to work")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Resume") {
                                timeClockManager.endBreak(at: timeClockManager.breakEnd)
                                isEndingBreak = false
                            }
                            .accessibilityIdentifier("EndBreakStopButton")
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel", role: .cancel) {
                                isEndingBreak = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium])
        }
    }

    private var shouldShowCurrentClockedIn: Bool {
        return payPeriod.contains(timeClockManager.clockInDate) && timeClockManager.clockInState != .clockedOut
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
