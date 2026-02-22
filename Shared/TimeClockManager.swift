import Foundation
import SwiftUI
import WidgetKit

/// A shared manager class for clock-in/clock-out state and logic,
/// used by both CurrentTimeEntryView and PayPeriodDetails to avoid code duplication.
@Observable
final class TimeClockManager {
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
    
    // MARK: - Clock Duration Calculation
    
    func updateClockInDuration() {
        let now = dateProvider.now
        switch clockInState {
        case .clockedOut:
            sinceClockIn = .zero
            clockInDuration = .zero
        case .clockedInWorking:
            let onBreak = breaks.reduce(TimeInterval()) { $0 + $1.interval }
            let since = clockInDate.distance(to: now)
            sinceClockIn = since
            clockInDuration = since - onBreak
        case .clockedInTakingABreak:
            let onBreak = breaks.reduce(TimeInterval()) { $0 + $1.interval }
            sinceClockIn = clockInDate.distance(to: now)
            let sinceBreakStart = max(TimeInterval(), breakStart.distance(to: now))
            clockInDuration = sinceClockIn - onBreak - sinceBreakStart
        }
    }
    
    // MARK: - Time Rounding
    
    func getRoundedNow() -> Date {
        return Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: dateProvider.now)
    }
    
    // MARK: - Clock In
    
    func clockIn(at date: Date) {
        guard clockInState == .clockedOut else {
            return
        }
        clockInDate = date
        breaks = [BreakEntry]()
        notes = ""
        clockInState = .clockedInWorking
        updateClockInDuration()
        reloadWidget()
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
        guard clockInState == .clockedInWorking && clockInDate != end else {
            return
        }
        
        let timeEntry = TimeEntry(from: clockInDate, to: end, notes: notes)
        timeEntry.breaks.append(contentsOf: breaks)
        modelContextInsert?(timeEntry)
        clockInState = .clockedOut
        breaks = []
        updateClockInDuration()
        reloadWidget()
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
        guard clockInState == .clockedInWorking else {
            return
        }
        
        breakStart = date
        clockInState = .clockedInTakingABreak
        updateClockInDuration()
        reloadWidget()
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
        guard clockInState == .clockedInTakingABreak else {
            return
        }
        
        breaks = breaks + [BreakEntry(start: breakStart, end: date)]
        clockInState = .clockedInWorking
        updateClockInDuration()
        reloadWidget()
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
    
    func reloadWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: "TimeKeenWidgetExtension")
    }
}
