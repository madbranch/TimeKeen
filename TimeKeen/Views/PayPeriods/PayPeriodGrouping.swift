import Foundation

extension Array where Element == TimeEntry {
  func group(by schedule: PayPeriodSchedule, ending periodEnd: Date) -> Dictionary<ClosedRange<Date>, [TimeEntry]> {
    return Dictionary(grouping: self, by: PayPeriodGrouping.getGroupByMethod(schedule: schedule, periodEnd: periodEnd))
  }
}

struct PayPeriodGrouping {
  static func getGroupByMethod(schedule: PayPeriodSchedule, periodEnd: Date) -> (TimeEntry) -> ClosedRange<Date> {
    return switch schedule {
    case .Weekly: getGroupByWeekly(periodEnd: periodEnd)
    case .Biweekly: getGroupByBiweekly(periodEnd: periodEnd)
    case .Monthly: getGroupByMonthly(periodEnd: periodEnd)
    case .EveryFourWeeks: getGroupByEveryFourWeeks(periodEnd: periodEnd)
    case .FirstAndSixteenth: getGroupByFirstAndSixteenth(periodEnd: periodEnd)
    }
  }
  
  private static func getGroupByWeekly(periodEnd: Date) -> (TimeEntry) -> ClosedRange<Date> {
    var calendar = Calendar(identifier: Calendar.current.identifier)
    calendar.firstWeekday = (calendar.component(.weekday, from: periodEnd) % calendar.weekdaySymbols.count) + 1
    return {
      let yearForWeekOfYear = calendar.component(.yearForWeekOfYear, from: $0.start)
      let weekOfYear = calendar.component(.weekOfYear, from: $0.start)
      let currentPeriodStart = calendar.date(from: DateComponents(weekOfYear: weekOfYear, yearForWeekOfYear: yearForWeekOfYear))!
      let currentPeriodEnd = calendar.date(byAdding: .day, value: calendar.weekdaySymbols.count - 1, to: currentPeriodStart)!
      return currentPeriodStart...currentPeriodEnd
    }
  }
  
  private static func getGroupByBiweekly(periodEnd: Date) -> (TimeEntry) -> ClosedRange<Date> {
    let calendar = Calendar.current
    let biweekdays = calendar.weekdaySymbols.count * 2
    let periodStart = calendar.date(byAdding: .day, value: 1, to: periodEnd)!
    return {
      let start = $0.start
      let deltaComponents = calendar.dateComponents([.day], from: periodStart, to: start)
      let deltaDays = deltaComponents.day!
      let delta = (deltaDays / biweekdays) * biweekdays
      let currentPeriodStart = calendar.date(byAdding: .day, value: delta, to: periodEnd)!
      let currentPeriodEnd = calendar.date(byAdding: .day, value: biweekdays - 1, to: currentPeriodStart)!
      return currentPeriodStart...currentPeriodEnd
    }
  }
  
  private static func getGroupByMonthly(periodEnd: Date) -> (TimeEntry) -> ClosedRange<Date> {
    //let calendar = Calendar.current
    //let periodStart = calendar.date(byAdding: .day, value: 1, to: calendar.date(byAdding: .month, value: -1, to: periodEnd)!)!
    return {
      let start = $0.start
      return start...$0.end
    }
  }
  
  private static func getGroupByEveryFourWeeks(periodEnd: Date) -> (TimeEntry) -> ClosedRange<Date> {
    return getGroupByWeekly(periodEnd: periodEnd)
  }
  
  private static func getGroupByFirstAndSixteenth(periodEnd: Date) -> (TimeEntry) -> ClosedRange<Date> {
    return getGroupByWeekly(periodEnd: periodEnd)
  }
}
