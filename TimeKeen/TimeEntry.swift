import SwiftData
import Foundation

@Model
class TimeEntry {
  init(from start: Date, to end: Date) {
    self.start = start
    self.end = end
  }
  var start: Date
  var end: Date
}
