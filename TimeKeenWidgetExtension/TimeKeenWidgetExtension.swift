import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        Self.getEmptyEntry()
    }
    
    func getSnapshot(in context: Context, completion: @escaping @Sendable (SimpleEntry) -> Void) {
        completion(Self.getUpdatedEntry())
    }
    
    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<SimpleEntry>) -> Void) {
        let entry = Self.getUpdatedEntry()
        // We specify to request a new timeline at the end of the pay period to make sure the current pay period is always up-to-date.
        completion(Timeline(entries: [entry], policy: .after(entry.payPeriod.upperBound)))
    }
    
    static func getEmptyEntry() -> SimpleEntry {
        let emptyPayPeriod = Date.now.getPayPeriod(schedule: .Weekly, periodEnd: Calendar.current.date(from: DateComponents(year: 2024, month: 07, day: 21))!)
        return SimpleEntry(date: .now, clockInState: .clockedOut, clockInDate: .now, breakStart: .now, onBreak: TimeInterval(), payPeriod: emptyPayPeriod)
    }
    
    static func getUpdatedEntry() -> SimpleEntry {
        guard let userDefaults = SharedData.userDefaults else {
            return Self.getEmptyEntry()
        }
        
        return getUpdatedEntry(from: userDefaults)
    }
   
    static func getUpdatedEntry(from userDefaults: UserDefaults) -> SimpleEntry {
        let clockInState = userDefaults.clockInState
        let clockInDate = userDefaults.clockInDate ?? .now
        let breakStart = userDefaults.breakStart ?? .now
        let breaks = userDefaults.breaks ?? []
        let onBreak = breaks.reduce(TimeInterval()) { $0 + $1.interval }
        let payPeriodSchedule = userDefaults.payPeriodSchedule
        let endOfLastPayPeriod = userDefaults.endOfLastPayPeriod
        let payPeriod = Date.now.getPayPeriod(schedule: payPeriodSchedule, periodEnd: endOfLastPayPeriod)
        let entry = SimpleEntry(date: .now, clockInState: clockInState, clockInDate: clockInDate, breakStart: breakStart, onBreak: onBreak, payPeriod: payPeriod)
        return entry
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    let clockInState: ClockInState
    let clockInDate: Date
    let breakStart: Date
    let onBreak: TimeInterval
    let payPeriod: ClosedRange<Date>
}

struct TimeKeenWidgetExtensionEntryView : View {
    var entry: Provider.Entry
    @Query var timeEntries: [TimeEntry]

    init(entry: Provider.Entry) {
        self.entry = entry
        _timeEntries = Query(filter: #Predicate<TimeEntry> { [payPeriod = self.entry.payPeriod] timeEntry in
            return timeEntry.start >= payPeriod.lowerBound && timeEntry.start <= payPeriod.upperBound
        })
    }

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            Text("C")
        case .accessoryRectangular:
            Text("Rect")
        case .accessoryInline:
            Text("Inline")
        case .systemSmall:
            switch entry.clockInState {
            case .clockedOut:
                Text("Clocked Out")
            case .clockedInWorking:
                VStack {
                    Text("Working")
                        .font(.caption)
                    
                    let timerDate = entry.clockInDate + entry.onBreak
                    
                    if timerDate > .now {
                        Text("--")
                    } else {
                        Text("\(timerDate, style: .timer)")
                            .multilineTextAlignment(.center)
                            .font(.headline)
                    }
                    
                    let payPeriodOnTheClock: TimeInterval = timeEntries.reduce(TimeInterval()) { $0 + $1.onTheClock }
                    let payPeriodTimerDate = entry.clockInDate + entry.onBreak - payPeriodOnTheClock
                    
                    Text( "Total \(payPeriodTimerDate, style: .timer)")
                        .multilineTextAlignment(.center)
                        .font(.caption)
                }
            case .clockedInTakingABreak:
                Text("On Break")
            }
        case .systemMedium:
            Text("Medium")
        case .systemLarge:
            Text("Large")
        case .systemExtraLarge:
            Text("XLarge")
        @unknown default:
            Text("Unknown widget family")
        }
    }
}

// globals are lazy
fileprivate let modelContainer: ModelContainer = {
    do {
        return try ModelContainer(for: TimeEntry.self, BreakEntry.self, configurations: ModelConfiguration(isStoredInMemoryOnly: false))
    } catch {
        fatalError("Failed to configure SwiftData container.")
    }
}()

struct TimeKeenWidgetExtension: Widget {
    let kind: String = "TimeKeenWidgetExtension"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TimeKeenWidgetExtensionEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .modelContainer(modelContainer)
        }
        #if os(watchOS)
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
        #elseif os(iOS)
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        #else
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
        #endif
    }
}

#Preview(as: .systemSmall) {
    TimeKeenWidgetExtension()
} timeline: {
    Provider.getEmptyEntry()
}
