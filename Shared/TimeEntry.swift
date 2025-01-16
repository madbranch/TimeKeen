import SwiftData
import Foundation

@Model
public class TimeEntry: Encodable {
    var start: Date
    var end: Date
    var notes: String = ""
    @Relationship(deleteRule: .cascade, inverse: \BreakEntry.timeEntry)
    var breaks = [BreakEntry]()
    init(from start: Date, to end: Date, notes: String = "") {
        self.start = start
        self.end = end
        self.notes = notes
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
