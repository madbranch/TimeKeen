import Foundation
import SwiftData
import AppIntents

struct ClockOut: AppIntent {
    static let title: LocalizedStringResource = "Clock Out"
    static let description = IntentDescription("Clock out and stop working.")
    
    @Parameter(title: "When", description: "When to clock out.")
    var when: Date
    private let dateProvider: DateProvider
    
    init() {
        dateProvider = RealDateProvider()
    }
    
    init(dateProvider: DateProvider) {
        self.dateProvider = dateProvider
    }
    
    @Dependency
    private var modelContainer: ModelContainer
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let service = TimeClockActionService(
            persistClockOut: { [modelContainer] timeEntry in
                modelContainer.mainContext.insert(timeEntry)
                try modelContainer.mainContext.save()
            },
            reloadWidgets: TimeClockManager.reloadWidgets
        )

        switch service.clockOut(at: when, notes: SharedData.userDefaults?.notes) {
        case let .success(mutation):
            return Calendar.current.isDate(mutation.effectiveDate, inSameDayAs: dateProvider.now)
            ? .result(dialog: "Clocking out at \(Formatting.startEndFormatter.string(from: mutation.effectiveDate))")
            : .result(dialog: "Clocking out on \(Formatting.startEndWithDateFormatter.string(from: mutation.effectiveDate))")
        case let .failure(error):
            return .result(dialog: IntentDialog(stringLiteral: error.localizedDescription))
        }
    }
}
