import SwiftData
import Foundation

@Model
class TimeEntry {
  var start: Date
  var end: Date
  var notes: String = ""
  var breaks = [BreakEntry]()
  init(from start: Date, to end: Date, notes: String) {
    self.start = start
    self.end = end
    self.notes = notes
  }
}
