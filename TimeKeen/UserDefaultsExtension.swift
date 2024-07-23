import Foundation

extension UserDefaults {
  var minuteInterval: Int {
    return UserDefaults.standard.object(forKey: "MinuteInterval") as? Int ?? 15
  }
  
  var payPeriodSchedule: PayPeriodSchedule {
    return UserDefaults.standard.object(forKey: "PayPeriodSchedule") as? PayPeriodSchedule ?? .Weekly
  }
}
