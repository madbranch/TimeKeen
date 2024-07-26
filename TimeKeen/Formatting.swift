import Foundation

class Formatting {
  static let timeIntervalFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.zeroFormattingBehavior = .pad
    formatter.allowedUnits = [.hour, .minute]
    return formatter
  }()

  static let startEndWithDateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
  }()
  
  static let startEndFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
  }()
  
  static let yearlessDateformatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale.current
    formatter.setLocalizedDateFormatFromTemplate("MMM d")
    return formatter
  }()
  
  static func getRoundedDate() -> Date {
    return getRoundedDate(minuteInterval: Double(UserDefaults.standard.minuteInterval))
  }
  
  static func getRoundedDate(minuteInterval: Double) -> Date {
    let date = Date()
    let components = Calendar.current.dateComponents([.minute], from: date)
    
    guard let minute = components.minute else {
      return date
    }
    
    let roundedMinutes = Int((Double(minute) / minuteInterval).rounded(.toNearestOrAwayFromZero) * minuteInterval)
    
    return Calendar.current.date(byAdding: .minute, value: roundedMinutes - minute, to: date) ?? Date()
  }
}
