import Foundation

extension Calendar {
  func dateOnly(from date: Date) -> Date? {
    return self.date(from: self.dateComponents([.year, .month, .day], from: date))
  }
  func previousDay(from date: Date) -> Date? {
    return self.date(byAdding: .day, value: -1, to: date)
  }
  
  func nextDay(from date: Date) -> Date? {
    return self.date(byAdding: .day, value: 1, to: date)
  }
  
  func endOfDay(from date: Date) -> Date? {
    guard let nextDay = self.nextDay(from: date) else {
      return nil
    }
    
    return self.date(byAdding: .second, value: -1, to: nextDay)
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
  
  func getRoundedDate(minuteInterval: Int, from date: Date) -> Date {
    let components = self.dateComponents([.minute], from: date)
    
    guard let minute = components.minute else {
      return date
    }
    
    let roundedMinutes = Int((Double(minute) / Double(minuteInterval)).rounded(.toNearestOrAwayFromZero)) * minuteInterval
    
    guard let roundedMinutesDate = self.date(byAdding: .minute, value: roundedMinutes - minute, to: date) else {
      return date
    }
    
    let roundedComponents = self.dateComponents([.year, .month, .day, .hour, .minute], from: roundedMinutesDate)
    
    return self.date(from: roundedComponents) ?? date
  }
}
