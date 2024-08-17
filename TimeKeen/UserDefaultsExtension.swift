import Foundation

extension UserDefaults {
  var minuteInterval: Int {
    return self.object(forKey: SharedData.Keys.minuteInterval.rawValue) as? Int ?? 15
  }
  
  var payPeriodSchedule: PayPeriodSchedule {
    return self.object(forKey: SharedData.Keys.payPeriodSchedule.rawValue) as? PayPeriodSchedule ?? .Weekly
  }
  
  var endOfLastPayPeriod: Date {
    return self.object(forKey: SharedData.Keys.endOfLastPayPeriod.rawValue) as? Date ?? Calendar.current.date(from: DateComponents(year: 2024, month: 07, day: 21))!
  }
  
  var breaks: [BreakItem]? {
    guard let data = self.object(forKey: SharedData.Keys.breaks.rawValue) as? Data else {
      return nil
    }
    
    guard let breaks = try? JSONDecoder().decode([BreakItem].self, from: data) else {
      return nil
    }
    
    return breaks
  }
  
  var breakStart: Date? {
    return self.object(forKey: SharedData.Keys.breaks.rawValue) as? Date
  }
  
  var clockInDate: Date? {
    return self.object(forKey: SharedData.Keys.breaks.rawValue) as? Date
  }
}
