import Foundation

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
  
  func getRoundedDate(minuteInterval: Int, from date: Date) -> Date {
    let components = self.dateComponents([.minute], from: date)
    
    guard let minute = components.minute else {
      return date
    }
    
    let roundedMinutes = Int((Double(minute) / Double(minuteInterval)).rounded(.toNearestOrAwayFromZero)) * minuteInterval
    
    return self.date(byAdding: .minute, value: roundedMinutes - minute, to: date) ?? Date()
  }
}
