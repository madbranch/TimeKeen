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
    
    static func getYearlessDateFormatter(locale: Locale) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.setLocalizedDateFormatFromTemplate("MMM d")
        return formatter
    }
    
    static let yearlessDateformatter = {
        return getYearlessDateFormatter(locale: Locale.current)
    }()
    
    static func getHourFormatter(locale: Locale) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.setLocalizedDateFormatFromTemplate("HH")
        return formatter
    }
    
    static let hourFormatter = {
        return getHourFormatter(locale: Locale.current)
    }()
    
    static func getMinuteFormatter(locale: Locale) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.setLocalizedDateFormatFromTemplate("mm")
        return formatter
    }
    
    static let minuteFormatter = {
        return getMinuteFormatter(locale: Locale.current)
    }()
    
    static let fileNameDateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
}
