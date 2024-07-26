import Foundation

extension BreakEntry {
  var interval: TimeInterval {
    return start.distance(to: end)
  }
}
