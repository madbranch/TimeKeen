import Foundation
import AppIntents
import WidgetKit

struct ClockIn: AppIntent, WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Clock In"
    static let description = IntentDescription("Clock in and start working.")
    
    @Parameter(title: "When", description: "When to clock in.")
    var when: Date?
    private let dateProvider: DateProvider
    
    init() {
        dateProvider = RealDateProvider()
    }
    
    init(dateProvider: DateProvider) {
        self.dateProvider = dateProvider
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        var actualWhen = when
        
        if actualWhen == nil {
            do {
                actualWhen = try await $when.requestValue("When do you want to clock in?")
            } catch {
                return .result(dialog: "Failed to clock in.")
            }
        }
        
        let service = TimeClockActionService(
            reloadWidgets: {
                WidgetCenter.shared.reloadTimelines(ofKind: "TimeKeenWidgetExtension")
            }
        )
        switch service.clockIn(at: actualWhen!) {
        case let .success(mutation):
            return Calendar.current.isDate(mutation.effectiveDate, inSameDayAs: dateProvider.now)
            ? .result(dialog: "Clocking in at \(Formatting.startEndFormatter.string(from: mutation.effectiveDate))")
            : .result(dialog: "Clocking in on \(Formatting.startEndWithDateFormatter.string(from: mutation.effectiveDate))")
        case let .failure(error):
            return .result(dialog: IntentDialog(stringLiteral: error.localizedDescription))
        }
    }
}
