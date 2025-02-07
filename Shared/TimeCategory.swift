import SwiftData
import Foundation

@Model
public class TimeCategory: Encodable {
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \TimeEntry.category)
    var entries = [TimeEntry]()
    var minuteInterval = 15
    var payPeriodSchedule = PayPeriodSchedule.Weekly
    var endOfLastPayPeriod = Calendar.current.date(from: DateComponents(year: 2024, month: 07, day: 21))!
    @Relationship(deleteRule: .cascade, inverse: \BreakEntry.category)
    var breaks = [BreakEntry]()
    var breakStart: Date? = nil
    var notes: String? = nil
    var clockInDate: Date? = nil
    var clockInState = ClockInState.clockedOut
    init(named name: String) {
        self.name = name
        entries = [TimeEntry]()
    }
    enum CodingKeys: String, CodingKey {
        case name, entries
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(entries, forKey: .entries)
    }
}
