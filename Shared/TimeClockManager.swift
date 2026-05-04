import Foundation
import SwiftUI
import WidgetKit

/// A shared manager class for clock-in/clock-out state and logic,
/// used by both CurrentTimeEntryView and PayPeriodDetails to avoid code duplication.
@Observable
final class TimeClockManager {
    private static let widgetKind = "TimeKeenWidgetExtension"

    // MARK: - Dependencies
    
    var dateProvider: DateProvider = RealDateProvider()
    var modelContextInsert: ((TimeEntry) -> Void)?
    
    // MARK: - Published State (computed from AppStorage values)
    
    var clockInDuration: TimeInterval = .zero
    var sinceClockIn: TimeInterval = .zero
    
    // MARK: - AppStorage-backed properties
    
    @ObservationIgnored
    @AppStorage(SharedData.Keys.minuteInterval.rawValue, store: SharedData.userDefaults)
    var minuteInterval = 15
    
    @ObservationIgnored
    @AppStorage(SharedData.Keys.clockInState.rawValue, store: SharedData.userDefaults)
    var clockInState = ClockInState.clockedOut
    
    @ObservationIgnored
    @AppStorage(SharedData.Keys.clockInDate.rawValue, store: SharedData.userDefaults)
    var clockInDate = Date.now
    
    @ObservationIgnored
    @AppStorage(SharedData.Keys.breakStart.rawValue, store: SharedData.userDefaults)
    var breakStart = Date.now
    
    @ObservationIgnored
    @AppStorage(SharedData.Keys.breaks.rawValue, store: SharedData.userDefaults)
    var breaks = [BreakEntry]()
    
    @ObservationIgnored
    @AppStorage(SharedData.Keys.notes.rawValue, store: SharedData.userDefaults)
    var notes = ""
    
    // MARK: - UI State for date pickers
    
    var clockOutDate = Date.now
    var minClockOutDate = Date.now
    var breakEnd = Date.now
    var minBreakEndDate = Date.now
    var minBreakStart = Date.now
    
    // MARK: - Initialization
    
    init() {}

    private func makeActionService() -> TimeClockActionService {
        TimeClockActionService(
            persistClockOut: { [modelContextInsert] timeEntry in
                modelContextInsert?(timeEntry)
            },
            reloadWidgets: Self.reloadWidgets
        )
    }

    private func sync(from snapshot: TimeClockSnapshot) {
        sinceClockIn = snapshot.sinceClockIn
        clockInDuration = snapshot.clockInDuration
    }
    
    // MARK: - Clock Duration Calculation
    
    func updateClockInDuration() {
        sync(from: makeActionService().loadSnapshot(now: dateProvider.now))
    }
    
    // MARK: - Time Rounding
    
    func getRoundedNow() -> Date {
        makeActionService().roundedDate(for: dateProvider.now)
    }
    
    // MARK: - Clock In
    
    func clockIn(at date: Date) {
        guard case let .success(result) = makeActionService().clockIn(at: date) else {
            return
        }

        sync(from: result.snapshot)
    }
    
    // MARK: - Clock Out
    
    /// Prepares state for clocking out. Returns true if clock-out sheet should be shown.
    func startClockingOut() -> Bool {
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
    
    func clockOut(at end: Date, notes: String) {
        guard case let .success(result) = makeActionService().clockOut(at: end, notes: notes) else {
            return
        }

        sync(from: result.snapshot)
    }
    
    // MARK: - Break Management
    
    /// Prepares state for starting a break. Returns true if break-start sheet should be shown.
    func startTakingBreak() -> Bool {
        guard clockInState == .clockedInWorking else {
            return false
        }
        
        guard let newDate = Calendar.current.date(byAdding: .minute, value: minuteInterval, to: clockInDate) else {
            return false
        }
        
        minBreakStart = Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: newDate)
        breakStart = max(minBreakStart, Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: dateProvider.now))
        return true
    }
    
    func startBreak(at date: Date) {
        guard case let .success(result) = makeActionService().startBreak(at: date) else {
            return
        }

        sync(from: result.snapshot)
    }
    
    /// Prepares state for ending a break. Returns true if break-end sheet should be shown.
    func startEndingBreak() -> Bool {
        guard clockInState == .clockedInTakingABreak else {
            return false
        }
        
        guard let newDate = Calendar.current.date(byAdding: .minute, value: minuteInterval, to: breakStart) else {
            return false
        }
        
        minBreakEndDate = Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: newDate)
        breakEnd = max(minBreakEndDate, Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: dateProvider.now))
        return true
    }
    
    func endBreak(at date: Date) {
        guard case let .success(result) = makeActionService().endBreak(at: date) else {
            return
        }

        sync(from: result.snapshot)
    }
    
    // MARK: - Quick Actions
    
    func handle(_ quickAction: WorkAction) {
        switch quickAction {
        case .clockIn:
            clockIn(at: getRoundedNow())
        case .clockOut:
            if startClockingOut() {
                clockOut(at: clockOutDate, notes: notes)
            }
        case .startBreak:
            if startTakingBreak() {
                startBreak(at: breakStart)
            }
        case .endBreak:
            if startEndingBreak() {
                endBreak(at: breakEnd)
            }
        }
    }
    
    // MARK: - Widget
    
    static func reloadWidgets() {
        WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
    }

    func reloadWidget() {
        Self.reloadWidgets()
    }
}
