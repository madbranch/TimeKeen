import Foundation

struct DayGroup: Identifiable {
    let id: Date // The date-only component representing the day
    let entries: [TimeEntry]
    
    var first: TimeEntry? { entries.first }
}

extension Array where Element == TimeEntry {
    func groupByDay() -> [DayGroup] {
        guard let first = self.first,
              let firstDay = Calendar.current.dateOnly(from: first.start) else {
            return []
        }
        
        var result = [DayGroup]()
        let calendar = Calendar.current
        var day = firstDay
        var dailyTimeEntries = [TimeEntry]()
        
        for timeEntry in self {
            guard let currentDay = calendar.dateOnly(from: timeEntry.start) else {
                continue
            }
            
            if day == currentDay {
                dailyTimeEntries.append(timeEntry)
            } else {
                result.append(DayGroup(id: day, entries: dailyTimeEntries))
                day = currentDay
                dailyTimeEntries = [timeEntry]
            }
        }
        
        result.append(DayGroup(id: day, entries: dailyTimeEntries))
        return result
    }
    
    func group(by schedule: PayPeriodSchedule, ending periodEnd: Date) -> [PayPeriod] {
        guard let first = self.first else {
            return [PayPeriod]()
        }
        
        let groupByMethod = PayPeriodGrouping.getGroupByMethod(schedule: schedule, periodEnd: periodEnd)
        var result = [PayPeriod]()
        var payPeriodRange = groupByMethod(first.start)
        var timeEntries = [TimeEntry]()
        
        for timeEntry in self {
            let currentPayPeriodRange = groupByMethod(timeEntry.start)
            
            if payPeriodRange == currentPayPeriodRange {
                timeEntries.append(timeEntry)
            } else {
                result.append(PayPeriod(range: payPeriodRange, timeEntries: timeEntries))
                payPeriodRange = currentPayPeriodRange
                timeEntries = [timeEntry]
            }
        }
        
        result.append(PayPeriod(range: payPeriodRange, timeEntries: timeEntries))
        return result
    }
}

extension TimeEntry {
    func getPayPeriod(schedule: PayPeriodSchedule, periodEnd: Date) -> ClosedRange<Date> {
        return PayPeriodGrouping.getGroupByMethod(schedule: schedule, periodEnd: periodEnd)(self.start)
    }
}

extension Date {
    func getPayPeriod(schedule: PayPeriodSchedule, periodEnd: Date) -> ClosedRange<Date> {
        return PayPeriodGrouping.getGroupByMethod(schedule: schedule, periodEnd: periodEnd)(self)
    }
}

struct PayPeriodGrouping {
    static func getGroupByMethod(schedule: PayPeriodSchedule, periodEnd: Date) -> (Date) -> ClosedRange<Date> {
        return switch schedule {
        case .Weekly: getGroupByWeekly(periodEnd: periodEnd)
        case .Biweekly: getGroupByNWeekly(periodEnd: periodEnd, nbWeeks: 2)
        case .Monthly: getGroupByMonthly(periodEnd: periodEnd)
        case .EveryFourWeeks: getGroupByNWeekly(periodEnd: periodEnd, nbWeeks: 4)
        case .FirstAndSixteenth: getGroupByFirstAndSixteenth()
        }
    }
    
    private static func getGroupByWeekly(periodEnd: Date) -> (Date) -> ClosedRange<Date> {
        var calendar = Calendar(identifier: Calendar.current.identifier)
        calendar.firstWeekday = (calendar.component(.weekday, from: periodEnd) % calendar.weekdaySymbols.count) + 1
        return {
            let yearForWeekOfYear = calendar.component(.yearForWeekOfYear, from: $0)
            let weekOfYear = calendar.component(.weekOfYear, from: $0)
            let currentPeriodStart = calendar.date(from: DateComponents(weekOfYear: weekOfYear, yearForWeekOfYear: yearForWeekOfYear))!
            let currentPeriodEnd = calendar.endOfDay(from: calendar.date(byAdding: .day, value: calendar.weekdaySymbols.count - 1, to: currentPeriodStart)!)!
            return currentPeriodStart...currentPeriodEnd
        }
    }
    
    private static func getGroupByNWeekly(periodEnd: Date, nbWeeks: Int) -> (Date) -> ClosedRange<Date> {
        let calendar = Calendar.current
        let nbDays = calendar.weekdaySymbols.count * nbWeeks
        let periodStart = calendar.date(byAdding: .day, value: 1, to: periodEnd)!
        return { start in
            let deltaComponents = calendar.dateComponents([.day], from: periodStart, to: start)
            let deltaDays = deltaComponents.day!
            let delta = (deltaDays / nbDays) * nbDays
            let currentPeriodStart = calendar.date(byAdding: .day, value: delta, to: periodEnd)!
            let currentPeriodEnd = calendar.endOfDay(from: calendar.date(byAdding: .day, value: nbDays - 1, to: currentPeriodStart)!)!
            return currentPeriodStart...currentPeriodEnd
        }
    }
    
    private static func getGroupByMonthly(periodEnd: Date) -> (Date) -> ClosedRange<Date> {
        let calendar = Calendar.current
        let periodEndComponents = calendar.dateComponents([.year, .month, .day], from: periodEnd)
        return { start in
            let startComponents = calendar.dateComponents([.year, .month, .day], from: start)
            let nbDaysInStartMonth = calendar.range(of: .day, in: .month, for: start)!.count
            let startMonthEndPeriodDay = min(nbDaysInStartMonth, periodEndComponents.day!)
            
            if startComponents.day! <= startMonthEndPeriodDay {
                let currentPeriodEnd = calendar.date(from: DateComponents(year: startComponents.year, month: startComponents.month, day: startMonthEndPeriodDay))!
                let currentPeriodStart = calendar.periodStart(ending: currentPeriodEnd)!
                return currentPeriodStart...currentPeriodEnd
            }
            
            let currentPeriodStart = calendar.nextDay(from: calendar.date(from: DateComponents(year: startComponents.year, month: startComponents.month, day: startMonthEndPeriodDay))!)!
            let currentPeriodEnd = calendar.endOfDay(from: calendar.periodEnd(starting: currentPeriodStart)!)!
            return currentPeriodStart...currentPeriodEnd
        }
    }
    
    private static func getGroupByFirstAndSixteenth() -> (Date) -> ClosedRange<Date> {
        let calendar = Calendar.current
        return { start in
            let components = calendar.dateComponents([.year, .month, .day], from: start)
            
            if components.day! < 16 {
                return calendar.startMonth(from: start)!...calendar.date(from: DateComponents(year: components.year, month: components.month, day: 15))!
            }
            
            return calendar.date(from: DateComponents(year: components.year, month: components.month, day: 16))!...calendar.endOfDay(from: calendar.endMonth(from: start)!)!
        }
    }
}
