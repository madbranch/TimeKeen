import Foundation
import SwiftUI
import SwiftData

struct PayPeriodDetails: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query var timeEntries: [TimeEntry]
    private let payPeriod: ClosedRange<Date>
    
    init(for payPeriod: ClosedRange<Date>) {
        self.payPeriod = payPeriod
        _timeEntries = Query(filter: #Predicate<TimeEntry> { [payPeriod = self.payPeriod] timeEntry in
            return timeEntry.start >= payPeriod.lowerBound && timeEntry.start <= payPeriod.upperBound
        }, sort: \TimeEntry.start, order: .reverse)
    }
    
    var body: some View {
        List {
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
                
                if timeEntries.isEmpty {
                    dismiss()
                }
            }
        }
        .navigationTitle("\(Formatting.yearlessDateformatter.string(from: payPeriod.lowerBound)) - \(Formatting.yearlessDateformatter.string(from: payPeriod.upperBound))")
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
