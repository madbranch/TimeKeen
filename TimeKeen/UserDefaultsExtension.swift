import Foundation

extension UserDefaults {
  var minuteInterval: Int {
    return UserDefaults.standard.object(forKey: "MinuteInterval") as? Int ?? 15
  }
  
  var payPeriodSchedule: PayPeriodSchedule {
    return UserDefaults.standard.object(forKey: "PayPeriodSchedule") as? PayPeriodSchedule ?? .Weekly
  }
  
  var endOfLastPayPeriod: Date {
    return UserDefaults.standard.object(forKey: "EndOfLastPayPeriod") as? Date ?? Calendar.current.date(from: DateComponents(year: 2024, month: 07, day: 21))!
  }
}
