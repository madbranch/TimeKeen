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
    case .Biweekly: getGroupByNWeekly(periodEnd: periodEnd, nbWeeks: 2)
    case .Monthly: getGroupByMonthly(periodEnd: periodEnd)
    case .EveryFourWeeks: getGroupByNWeekly(periodEnd: periodEnd, nbWeeks: 4)
    case .FirstAndSixteenth: getGroupByFirstAndSixteenth()
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
  
  private static func getGroupByNWeekly(periodEnd: Date, nbWeeks: Int) -> (TimeEntry) -> ClosedRange<Date> {
    let calendar = Calendar.current
    let nbDays = calendar.weekdaySymbols.count * nbWeeks
    let periodStart = calendar.date(byAdding: .day, value: 1, to: periodEnd)!
    return {
      let start = $0.start
      let deltaComponents = calendar.dateComponents([.day], from: periodStart, to: start)
      let deltaDays = deltaComponents.day!
      let delta = (deltaDays / nbDays) * nbDays
      let currentPeriodStart = calendar.date(byAdding: .day, value: delta, to: periodEnd)!
      let currentPeriodEnd = calendar.date(byAdding: .day, value: nbDays - 1, to: currentPeriodStart)!
      return currentPeriodStart...currentPeriodEnd
    }
  }
  
  private static func getGroupByMonthly(periodEnd: Date) -> (TimeEntry) -> ClosedRange<Date> {
    let calendar = Calendar.current
    let periodEndComponents = calendar.dateComponents([.year, .month, .day], from: periodEnd)
    return {
      let start = $0.start
      let startComponents = calendar.dateComponents([.year, .month, .day], from: start)
      let nbDaysInStartMonth = calendar.range(of: .day, in: .month, for: start)!.count
      let startMonthEndPeriodDay = min(nbDaysInStartMonth, periodEndComponents.day!)
      
      if startComponents.day! <= startMonthEndPeriodDay {
        let currentPeriodEnd = calendar.date(from: DateComponents(year: startComponents.year, month: startComponents.month, day: startMonthEndPeriodDay))!
        let currentPeriodStart = calendar.periodStart(ending: currentPeriodEnd)!
        return currentPeriodStart...currentPeriodEnd
      }

      let currentPeriodStart = calendar.nextDay(from: calendar.date(from: DateComponents(year: startComponents.year, month: startComponents.month, day: startMonthEndPeriodDay))!)!
      let currentPeriodEnd = calendar.periodEnd(starting: currentPeriodStart)!
      return currentPeriodStart...currentPeriodEnd
    }
  }
  
  private static func getGroupByFirstAndSixteenth() -> (TimeEntry) -> ClosedRange<Date> {
    let calendar = Calendar.current
    return {
      let start = $0.start
      let components = calendar.dateComponents([.year, .month, .day], from: start)
      
      if components.day! < 16 {
        return calendar.startMonth(from: start)!...calendar.date(from: DateComponents(year: components.year, month: components.month, day: 15))!
      }
      
      return calendar.date(from: DateComponents(year: components.year, month: components.month, day: 16))!...calendar.endMonth(from: start)!
    }
  }
}
