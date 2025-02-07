import Foundation

class SharedData {
    static var userDefaults: UserDefaults? { UserDefaults(suiteName: "group.com.timekeen.maingroup") }
    
    enum Keys: String, CaseIterable {
        case minuteInterval = "MinuteInterval"
        case payPeriodSchedule = "PayPeriodSchedule"
        case endOfLastPayPeriod = "EndOfLastPayPeriod"
        case breaks = "Breaks"
        case breakStart = "BreakStart"
        case notes = "Notes"
        case clockInDate = "ClockInDate"
        case clockInState = "ClockInState"
        case categories = "Categories"
    }
}
