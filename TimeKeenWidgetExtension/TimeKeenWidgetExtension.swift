import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry.placeholderEntry
    }
    
    func getSnapshot(in context: Context, completion: @escaping @Sendable (SimpleEntry) -> Void) {
        completion(SimpleEntry.placeholderEntry)
    }
    
    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<SimpleEntry>) -> Void) {
        guard let userDefaults = SharedData.userDefaults else {
            let timeline = Timeline(entries: [SimpleEntry.placeholderEntry], policy: .never)
            completion(timeline)
            return
        }
        
        // We fetch information from user defaults.
        let clockInState = userDefaults.clockInState
        let clockInDate = userDefaults.clockInDate ?? .now
        let breakStart = userDefaults.breakStart ?? .now
        let breaks = userDefaults.breaks ?? []
        let onBreak = breaks.reduce(TimeInterval()) { $0 + $1.interval }
        let payPeriodSchedule = userDefaults.payPeriodSchedule
        let endOfLastPayPeriod = userDefaults.endOfLastPayPeriod
        let payPeriod = Date.now.getPayPeriod(schedule: payPeriodSchedule, periodEnd: endOfLastPayPeriod)
        
        // We fetch data from SwiftData
        let fetchDescriptor = FetchDescriptor(predicate: #Predicate<TimeEntry> { timeEntry in
            return timeEntry.start >= payPeriod.lowerBound && timeEntry.start <= payPeriod.upperBound
        })
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        let timeEntries = (try? modelContext.fetch(fetchDescriptor)) ?? []
        let payPeriodOnTheClock = timeEntries.reduce(TimeInterval()) { $0 + $1.interval }
        
        let entry = SimpleEntry(date: .now, clockInState: clockInState, clockInDate: clockInDate, breakStart: breakStart, onBreak: onBreak, payPeriod: payPeriod, payPeriodOnTheClock: payPeriodOnTheClock)
        
        // We specify to request a new timeline at the end of the pay period to make sure the current pay period is always up-to-date.
        let timeline = Timeline(entries: [entry], policy: .after(entry.payPeriod.upperBound))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    
    let clockInState: ClockInState
    let clockInDate: Date
    let breakStart: Date
    let onBreak: TimeInterval
    let payPeriod: ClosedRange<Date>
    let payPeriodOnTheClock: TimeInterval
    
    static var placeholderEntry: SimpleEntry {
        return SimpleEntry(date: .now, clockInState: .clockedOut, clockInDate: .now, breakStart: .now, onBreak: .zero, payPeriod: Date.now...Date.now, payPeriodOnTheClock: .zero)
    }
}

struct TimeKeenWidgetExtensionEntryView : View {
    var entry: Provider.Entry
    
    init(entry: Provider.Entry) {
        self.entry = entry
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
                if (entry.payPeriodOnTheClock <= TimeInterval.zero) {
                    Text("**--**\nsince \(Formatting.yearlessDateformatter.string(from: entry.payPeriod.lowerBound))")
                } else {
                    Text("**\(Formatting.timeIntervalFormatter.string(from: max(entry.payPeriodOnTheClock, TimeInterval())) ?? "--")**\nsince \(Formatting.yearlessDateformatter.string(from: entry.payPeriod.lowerBound))")
                }
            case .clockedInWorking:
                VStack {
                    let timerDate = entry.clockInDate + entry.onBreak
                    
                    if timerDate > .now {
                        Text("--")
                            .frame(maxHeight: .infinity, alignment: .topLeading)
                    } else {
                        Text("\(timerDate, style: .timer)")
                            .font(.largeTitle)
                            .fontDesign(.rounded)
                            .minimumScaleFactor(0.005)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    
                    let payPeriodTimerDate = entry.clockInDate + entry.onBreak - entry.payPeriodOnTheClock
                    
                    Text( "**\(payPeriodTimerDate, style: .timer)**\nsince \(Formatting.yearlessDateformatter.string(from: entry.payPeriod.lowerBound))")
                }
            case .clockedInTakingABreak:
                Text("On Break")
            }
        default:
            Text("Unsupported widget family")
        }
    }
}

struct TimeKeenWidgetExtension: Widget {
    let kind: String = "TimeKeenWidgetExtension"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TimeKeenWidgetExtensionEntryView(entry: entry)
                .containerBackground(ColorPalette.primary.color.gradient, for: .widget)
                .foregroundStyle(.white)
        }
#if os(watchOS)
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
#else
        .supportedFamilies([.systemSmall])
#endif
    }
}

#Preview(as: .systemSmall) {
    TimeKeenWidgetExtension()
} timeline: {
    SimpleEntry.placeholderEntry
}
