import Foundation

extension Array where Element == TimeEntry {
  func group(by schedule: PayPeriodSchedule, ending periodEnd: Date) -> Dictionary<ClosedRange<Date>, [TimeEntry]> {
    return Dictionary(grouping: self, by: PayPeriodGrouping.getGroupByMethod(schedule: schedule, periodEnd: periodEnd))
  }
}

extension Calendar {
  func previousDay(from date: Date) -> Date? {
    return self.date(byAdding: .day, value: -1, to: date)
  }
  
  func nextDay(from date: Date) -> Date? {
    return self.date(byAdding: .day, value: 1, to: date)
  }
  
  func previousMonth(from date: Date) -> Date? {
    return self.date(byAdding: .month, value: -1, to: date)
  }
  
  func nextMonth(from date: Date) -> Date? {
    return self.date(byAdding: .month, value: 1, to: date)
  }
  
  func startMonth(from date: Date) -> Date? {
    return self.date(from: self.dateComponents([.year, .month], from: date))
  }
  
  func endMonth(from date: Date) -> Date? {
    return self.previousDay(from: self.startMonth(from: self.nextMonth(from: date)!)!)!
  }
  
  func periodStart(ending periodEnd: Date) -> Date? {
    return self.nextDay(from: self.previousMonth(from: periodEnd)!)
  }
  
  func periodEnd(starting periodStart: Date) -> Date? {
    return self.nextMonth(from: self.previousDay(from: periodStart)!)
  }
}

struct PayPeriodGrouping {
  static func getGroupByMethod(schedule: PayPeriodSchedule, periodEnd: Date) -> (TimeEntry) -> ClosedRange<Date> {
    return switch schedule {
    case .Weekly: getGroupByWeekly(periodEnd: periodEnd)
    case .Biweekly: getGroupByNWeekly(periodEnd: periodEnd, nbWeeks: 2)
    case .Monthly: getGroupByMonthly(periodEnd: periodEnd)
    case .EveryFourWeeks: getGroupByNWeekly(periodEnd: periodEnd, nbWeeks: 4)
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
  
  private static func getGroupByFirstAndSixteenth(periodEnd: Date) -> (TimeEntry) -> ClosedRange<Date> {
    return getGroupByWeekly(periodEnd: periodEnd)
  }
}
