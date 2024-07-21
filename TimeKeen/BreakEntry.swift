import Foundation
import SwiftData

@Model
class BreakEntry {
  init(start: Date, end: Date) {
    self.start = start
    self.end = end
  }
  var start: Date
  var end: Date
}
