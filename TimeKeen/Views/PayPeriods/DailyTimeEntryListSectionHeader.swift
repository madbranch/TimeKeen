import SwiftUI

struct DailyTimeEntryListSectionHeader: View {
    var timeEntries: [TimeEntry]
    var extraDuration: TimeInterval = .zero

    var body: some View {
        HStack {
            if timeEntries.isEmpty {
                Text("---")
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(timeEntries[0].start.formatted(date: .complete, time: .omitted))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Text(Formatting.timeIntervalFormatter.string(from: (timeEntries.reduce(TimeInterval.zero) { $0 + $1.onTheClock }) + extraDuration) ?? "")
        }
    }
}

#Preview {
    let container = Previewing.modelContainer
    let timeEntries = Previewing.sameDayTimeEntries

    return DailyTimeEntryListSectionHeader(timeEntries: timeEntries)
        .modelContainer(container)
}
