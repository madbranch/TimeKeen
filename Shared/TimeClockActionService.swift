import Foundation

enum TimeClockActionError: LocalizedError, Equatable {
    case unavailable
    case alreadyClockedIn
    case notClockedIn
    case notWorking
    case missingClockInDate
    case invalidClockOutDate
    case persistenceUnavailable

    var errorDescription: String? {
        String(localized: localizedResource)
    }

    private var localizedResource: LocalizedStringResource {
        switch self {
        case .unavailable:
            return LocalizedStringResource(
                "timeclock.error.unavailable",
                defaultValue: "Time clock data is unavailable.",
                comment: "Time clock data is unavailable.")
        case .alreadyClockedIn:
            return LocalizedStringResource(
                "timeclock.error.alreadyClockedIn",
                defaultValue: "You're already clocked in.",
                comment: "User is already clocked in.")
        case .notClockedIn:
            return LocalizedStringResource(
                "timeclock.error.notClockedIn",
                defaultValue: "You're not clocked in.",
                comment: "User is not clocked in.")
        case .notWorking:
            return LocalizedStringResource(
                "timeclock.error.notWorking",
                defaultValue: "You're not working.",
                comment: "User is not currently working.")
        case .missingClockInDate:
            return LocalizedStringResource(
                "timeclock.error.missingClockInDate",
                defaultValue: "You're not properly clocked in.",
                comment: "Missing clock-in date.")
        case .invalidClockOutDate:
            return LocalizedStringResource(
                "timeclock.error.invalidClockOutDate",
                defaultValue: "Clock out time must be after clock in time.",
                comment: "Invalid clock-out date.")
        case .persistenceUnavailable:
            return LocalizedStringResource(
                "timeclock.error.persistenceUnavailable",
                defaultValue: "Clock out isn't available on this device right now.",
                comment: "Persistence unavailable.")
        }
    }
}

struct TimeClockMutationResult {
    let effectiveDate: Date
    let snapshot: TimeClockSnapshot
}

protocol TimeClockActionHandling {
    func loadSnapshot(now: Date) -> TimeClockSnapshot
    func roundedDate(for date: Date) -> Date
    func clockIn(at date: Date) -> Result<TimeClockMutationResult, TimeClockActionError>
    func clockInNow(now: Date) -> Result<TimeClockMutationResult, TimeClockActionError>
    func clockOut(at date: Date, notes: String?) -> Result<TimeClockMutationResult, TimeClockActionError>
    func clockOutNow(now: Date, notes: String?) -> Result<TimeClockMutationResult, TimeClockActionError>
    func startBreak(at date: Date) -> Result<TimeClockMutationResult, TimeClockActionError>
    func endBreak(at date: Date) -> Result<TimeClockMutationResult, TimeClockActionError>
}

final class TimeClockActionService: TimeClockActionHandling {
    typealias ClockOutPersistence = (TimeEntry) throws -> Void
    typealias WidgetReloader = () -> Void

    private let userDefaults: UserDefaults?
    private let calendar: Calendar
    private let persistClockOut: ClockOutPersistence?
    private let reloadWidgets: WidgetReloader

    init(
        userDefaults: UserDefaults? = SharedData.userDefaults,
        calendar: Calendar = .current,
        persistClockOut: ClockOutPersistence? = nil,
        reloadWidgets: @escaping WidgetReloader = {}
    ) {
        self.userDefaults = userDefaults
        self.calendar = calendar
        self.persistClockOut = persistClockOut
        self.reloadWidgets = reloadWidgets
    }

    func loadSnapshot(now: Date) -> TimeClockSnapshot {
        guard let userDefaults else {
            return .unavailable
        }

        let clockInState = userDefaults.clockInState
        guard let clockInDate = userDefaults.clockInDate, clockInState != .clockedOut else {
            return TimeClockSnapshot(
                clockInState: .clockedOut,
                clockInDate: nil,
                clockInDuration: .zero,
                sinceClockIn: .zero,
                canClockIn: true,
                canClockOut: false
            )
        }

        let breaks = userDefaults.breaks ?? []
        let breakDuration = breaks.reduce(TimeInterval.zero) { $0 + $1.interval }
        let sinceClockIn = clockInDate.distance(to: now)

        let clockInDuration: TimeInterval
        switch clockInState {
        case .clockedOut:
            clockInDuration = .zero
        case .clockedInWorking:
            clockInDuration = sinceClockIn - breakDuration
        case .clockedInTakingABreak:
            let activeBreakDuration: TimeInterval
            if let breakStart = userDefaults.breakStart {
                activeBreakDuration = max(TimeInterval.zero, breakStart.distance(to: now))
            } else {
                activeBreakDuration = .zero
            }
            clockInDuration = sinceClockIn - breakDuration - activeBreakDuration
        }

        return TimeClockSnapshot(
            clockInState: clockInState,
            clockInDate: clockInDate,
            clockInDuration: clockInDuration,
            sinceClockIn: sinceClockIn,
            canClockIn: clockInState == .clockedOut,
            canClockOut: clockInState == .clockedInWorking
        )
    }

    func roundedDate(for date: Date) -> Date {
        let minuteInterval = userDefaults?.minuteInterval ?? 15
        return calendar.getRoundedDate(minuteInterval: minuteInterval, from: date)
    }

    func clockIn(at date: Date) -> Result<TimeClockMutationResult, TimeClockActionError> {
        guard let userDefaults else {
            return .failure(.unavailable)
        }

        guard userDefaults.clockInState == .clockedOut else {
            return .failure(.alreadyClockedIn)
        }

        let clockInDate = roundedDate(for: date)
        userDefaults.notes = ""
        userDefaults.breaks = []
        userDefaults.breakStart = nil
        userDefaults.clockInDate = clockInDate
        userDefaults.clockInState = .clockedInWorking
        reloadWidgets()

        return .success(TimeClockMutationResult(
            effectiveDate: clockInDate,
            snapshot: loadSnapshot(now: clockInDate)
        ))
    }

    func clockInNow(now: Date) -> Result<TimeClockMutationResult, TimeClockActionError> {
        clockIn(at: now)
    }

    func clockOut(at date: Date, notes: String? = nil) -> Result<TimeClockMutationResult, TimeClockActionError> {
        guard let userDefaults else {
            return .failure(.unavailable)
        }

        guard userDefaults.clockInState == .clockedInWorking else {
            return .failure(.notWorking)
        }

        guard let clockInDate = userDefaults.clockInDate else {
            return .failure(.missingClockInDate)
        }

        guard let persistClockOut else {
            return .failure(.persistenceUnavailable)
        }

        let clockOutDate = roundedDate(for: date)
        guard clockOutDate != clockInDate else {
            return .failure(.invalidClockOutDate)
        }

        let timeEntry = TimeEntry(from: clockInDate, to: clockOutDate, notes: notes ?? userDefaults.notes ?? "")
        timeEntry.breaks.append(contentsOf: userDefaults.breaks ?? [])

        do {
            try persistClockOut(timeEntry)
        } catch {
            return .failure(.persistenceUnavailable)
        }

        userDefaults.breakStart = nil
        userDefaults.breaks = []
        userDefaults.clockInState = .clockedOut
        reloadWidgets()

        return .success(TimeClockMutationResult(
            effectiveDate: clockOutDate,
            snapshot: loadSnapshot(now: clockOutDate)
        ))
    }

    func clockOutNow(now: Date, notes: String? = nil) -> Result<TimeClockMutationResult, TimeClockActionError> {
        clockOut(at: now, notes: notes)
    }

    func startBreak(at date: Date) -> Result<TimeClockMutationResult, TimeClockActionError> {
        guard let userDefaults else {
            return .failure(.unavailable)
        }

        guard userDefaults.clockInState == .clockedInWorking else {
            return .failure(.notWorking)
        }

        let breakStart = roundedDate(for: date)
        userDefaults.breakStart = breakStart
        userDefaults.clockInState = .clockedInTakingABreak
        reloadWidgets()

        return .success(TimeClockMutationResult(
            effectiveDate: breakStart,
            snapshot: loadSnapshot(now: breakStart)
        ))
    }

    func endBreak(at date: Date) -> Result<TimeClockMutationResult, TimeClockActionError> {
        guard let userDefaults else {
            return .failure(.unavailable)
        }

        guard userDefaults.clockInState == .clockedInTakingABreak else {
            return .failure(.notClockedIn)
        }

        guard let breakStart = userDefaults.breakStart else {
            return .failure(.missingClockInDate)
        }

        let breakEnd = roundedDate(for: date)
        userDefaults.breaks = (userDefaults.breaks ?? []) + [BreakEntry(start: breakStart, end: breakEnd)]
        userDefaults.breakStart = nil
        userDefaults.clockInState = .clockedInWorking
        reloadWidgets()

        return .success(TimeClockMutationResult(
            effectiveDate: breakEnd,
            snapshot: loadSnapshot(now: breakEnd)
        ))
    }
}
