import Foundation
import SwiftData

@Model
class BreakEntry: Codable {
    init(start: Date, end: Date, timeEntry: TimeEntry? = nil, category: TimeCategory? = nil) {
        assert(BreakEntry.isZeroSecond(start))
        assert(BreakEntry.isZeroSecond(end))
        self.start = start
        self.end = end
        self.timeEntry = timeEntry
        self.category = category
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        start = try container.decode(Date.self, forKey: .start)
        end = try container.decode(Date.self, forKey: .end)
    }
    
    var timeEntry: TimeEntry?
    var category: TimeCategory?
    var start: Date
    var end: Date
    
    enum CodingKeys: String, CodingKey {
        case start, end
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
    }
    
    private static func isZeroSecond(_ date: Date) -> Bool {
        switch Calendar.current.dateComponents([.second], from: date).second {
        case 0: true
        case nil: true
        default: false
        }
    }
}

