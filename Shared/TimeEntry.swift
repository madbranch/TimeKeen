import SwiftData
import Foundation

@Model
public class TimeEntry: Encodable {
    var start: Date
    var end: Date
    var notes: String = ""
    @Relationship(deleteRule: .cascade, inverse: \BreakEntry.timeEntry)
    var breaks = [BreakEntry]()
    var category: TimeCategory?
    init(from start: Date, to end: Date, notes: String = "", category: TimeCategory? = nil) {
        self.start = start
        self.end = end
        self.notes = notes
    }
    
    static func predicate(start: Date, end: Date) -> Predicate<TimeEntry> {
        return #Predicate<TimeEntry> { $0.start >= start && $0.start <= end }
    }

    enum CodingKeys: String, CodingKey {
        case start, end, breaks, notes
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
        try container.encode(notes, forKey: .notes)
        try container.encode(breaks, forKey: .breaks)
    }
}


