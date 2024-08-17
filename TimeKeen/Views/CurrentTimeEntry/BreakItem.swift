import Foundation

struct BreakItem: Codable {
  let start: Date
  let end: Date
  
  var interval: TimeInterval {
    return start.distance(to: end)
  }
}
