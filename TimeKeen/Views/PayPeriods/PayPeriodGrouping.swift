import Foundation

extension Array where Element == TimeEntry {
  func group(by schedule: PayPeriodSchedule, ending periodEnd: Date) -> Dictionary<Date, [TimeEntry]> {
    return Dictionary(grouping: self, by: PayPeriodGrouping.getGroupByMethod(schedule: schedule, periodEnd: periodEnd))
  }
}

struct PayPeriodGrouping {
  static func getGroupByMethod(schedule: PayPeriodSchedule, periodEnd: Date) -> (TimeEntry) -> Date {
    return switch schedule {
    case .Weekly: getGroupByWeekly(periodEnd: periodEnd)
    case .Biweekly: getGroupByBiweekly(periodEnd: periodEnd)
    case .Monthly: getGroupByMonthly(periodEnd: periodEnd)
    case .EveryFourWeeks: getGroupByEveryFourWeeks(periodEnd: periodEnd)
    case .FirstAndSixteenth: getGroupByFirstAndSixteenth(periodEnd: periodEnd)
    }
  }
  
  private static func getGroupByWeekly(periodEnd: Date) -> (TimeEntry) -> Date {
    var calendar = Calendar(identifier: Calendar.current.identifier)
    calendar.firstWeekday = (calendar.component(.weekday, from: periodEnd) % calendar.weekdaySymbols.count) + 1
    return {
      let yearForWeekOfYear = calendar.component(.yearForWeekOfYear, from: $0.start)
      let weekOfYear = calendar.component(.weekOfYear, from: $0.start)
      return calendar.date(from: DateComponents(weekOfYear: weekOfYear, yearForWeekOfYear: yearForWeekOfYear))!
    }
  }
  
  private static func getGroupByBiweekly(periodEnd: Date) -> (TimeEntry) -> Date {
    var calendar = Calendar(identifier: Calendar.current.identifier)
    calendar.firstWeekday = 2
    return {
      let yearForWeekOfYear = calendar.component(.yearForWeekOfYear, from: $0.start)
      let weekOfYear = calendar.component(.weekOfYear, from: $0.start)
      return calendar.date(from: DateComponents(weekOfYear: weekOfYear, yearForWeekOfYear: yearForWeekOfYear))!
    }
  }
  
  private static func getGroupByMonthly(periodEnd: Date) -> (TimeEntry) -> Date {
    var calendar = Calendar(identifier: Calendar.current.identifier)
    calendar.firstWeekday = 2
    return {
      let yearForWeekOfYear = calendar.component(.yearForWeekOfYear, from: $0.start)
      let weekOfYear = calendar.component(.weekOfYear, from: $0.start)
      return calendar.date(from: DateComponents(weekOfYear: weekOfYear, yearForWeekOfYear: yearForWeekOfYear))!
    }
  }
  
  private static func getGroupByEveryFourWeeks(periodEnd: Date) -> (TimeEntry) -> Date {
    var calendar = Calendar(identifier: Calendar.current.identifier)
    calendar.firstWeekday = 2
    return {
      let yearForWeekOfYear = calendar.component(.yearForWeekOfYear, from: $0.start)
      let weekOfYear = calendar.component(.weekOfYear, from: $0.start)
      return calendar.date(from: DateComponents(weekOfYear: weekOfYear, yearForWeekOfYear: yearForWeekOfYear))!
    }
  }
  
  private static func getGroupByFirstAndSixteenth(periodEnd: Date) -> (TimeEntry) -> Date {
    var calendar = Calendar(identifier: Calendar.current.identifier)
    calendar.firstWeekday = 2
    return {
      let yearForWeekOfYear = calendar.component(.yearForWeekOfYear, from: $0.start)
      let weekOfYear = calendar.component(.weekOfYear, from: $0.start)
      return calendar.date(from: DateComponents(weekOfYear: weekOfYear, yearForWeekOfYear: yearForWeekOfYear))!
    }
  }
}
