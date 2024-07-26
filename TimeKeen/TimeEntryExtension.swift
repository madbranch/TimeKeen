import Foundation

extension TimeEntry {
  var duration: Duration {
    let components = Calendar.current.dateComponents([.hour, .minute], from: start, to: end)
    
    if let hour = components.hour, let minute = components.minute {
      return Duration.seconds(hour * 60 * 60 + minute * 60)
    } else {
      return Duration.zero
    }
  }
  
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
