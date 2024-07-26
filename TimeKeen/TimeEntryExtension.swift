import Foundation

extension TimeEntry {
  var interval: TimeInterval {
    return start.distance(to: end)
  }
  
  var onBreak: TimeInterval {
    return breaks.reduce(TimeInterval()) { $0 + $1.interval }
  }
  
  var onTheClock: TimeInterval {
    return interval - onBreak
  }
}
