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
}
