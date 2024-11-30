import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        Self.getEmptyEntry()
    }
    
    func getSnapshot(in context: Context, completion: @escaping @Sendable (SimpleEntry) -> Void) {
        completion(Self.getUpdatedEntry())
    }
    
    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<SimpleEntry>) -> Void) {
        let entry = Self.getUpdatedEntry()
        // let policy = Self.getTimelineReloadPolicy(for: entry)
        completion(Timeline(entries: [entry], policy: .never))
    }
    
    static func getEmptyEntry() -> SimpleEntry {
        SimpleEntry(date: .now, clockInState: .clockedOut, clockInDate: .now, breakStart: .now, onBreak: TimeInterval())
    }
    
    static func getDuration(for entry: SimpleEntry) -> TimeInterval {
        switch entry.clockInState {
        case .clockedOut:
            return .zero
        case .clockedInWorking:
            let sinceClockIn = entry.clockInDate.distance(to: .now)
            let clockInDuration = sinceClockIn - entry.onBreak
            return clockInDuration
        case .clockedInTakingABreak:
            let sinceClockIn = entry.clockInDate.distance(to: .now)
            let clockInDuration = sinceClockIn - entry.onBreak
            let sinceBreakStart = max(TimeInterval(), entry.breakStart.distance(to: .now))
            return sinceBreakStart
        }
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
        let entry = SimpleEntry(date: .now, clockInState: clockInState, clockInDate: clockInDate, breakStart: breakStart, onBreak: onBreak)
        return entry
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    
    let clockInState: ClockInState
    let clockInDate: Date
    let breakStart: Date
    let onBreak: TimeInterval
}

struct TimeKeenWidgetExtensionEntryView : View {
    var entry: Provider.Entry
    
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
                    
                    let timerDate = entry.clockInDate + entry.onBreak
                    
                    if timerDate > .now {
                        Text("--")
                    }
                    else {
                        Text("\(timerDate, style: .timer)")
                            .multilineTextAlignment(.center)
                    }
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

struct TimeKeenWidgetExtension: Widget {
    let kind: String = "TimeKeenWidgetExtension"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TimeKeenWidgetExtensionEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
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
