import Foundation

struct TimeClockSnapshot: Equatable {
    let clockInState: ClockInState
    let clockInDate: Date?
    let clockInDuration: TimeInterval
    let sinceClockIn: TimeInterval
    let canClockIn: Bool
    let canClockOut: Bool

    static let unavailable = TimeClockSnapshot(
        clockInState: .clockedOut,
        clockInDate: nil,
        clockInDuration: .zero,
        sinceClockIn: .zero,
        canClockIn: false,
        canClockOut: false
    )
}

