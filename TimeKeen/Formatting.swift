import Foundation

class Formatting {
  static let durationStyle = Duration.TimeFormatStyle(pattern: .hourMinute)

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
    let date = Date()
    let components = Calendar.current.dateComponents([.minute], from: date)
    
    guard let minute = components.minute else {
      return date
    }
    
    let roundedMinutes = Int((Double(minute) / 15.0).rounded(.toNearestOrAwayFromZero) * 15.0)
    
    return Calendar.current.date(byAdding: .minute, value: roundedMinutes - minute, to: date) ?? Date()
  }
}
