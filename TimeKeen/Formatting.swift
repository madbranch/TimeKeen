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
}
