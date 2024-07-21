import SwiftData
import Foundation

@Model
class TimeEntry {
  init(from start: Date, to end: Date, notes: String) {
    self.start = start
    self.end = end
    self.notes = notes
  }
  var start: Date
  var end: Date
  var notes: String = ""
}
