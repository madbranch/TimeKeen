import Foundation

extension TimeEntry {
  var duration: String {
    let components = Calendar.current.dateComponents([.hour, .minute], from: start, to: end)
    
    if let hour = components.hour, let minute = components.minute  {
      return "\(String(format: "%02d", hour)):\(String(format: "%02d", minute))"
    } else {
      return"00:00"
    }
  }
}
