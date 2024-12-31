import Foundation

extension UserDefaults {
    func date(forKey defaultName: String) -> Date? {
        return self.object(forKey: defaultName) as? Date
    }
    
    var minuteInterval: Int {
        get {
            let result = self.integer(forKey: SharedData.Keys.minuteInterval.rawValue)
            
            return result > 0 ? result : 15
        }
        set(newMinuteInterval) {
            if newMinuteInterval <= 0 {
                self.removeObject(forKey: SharedData.Keys.minuteInterval.rawValue)
                return
            }
            
            self.set(newMinuteInterval, forKey: SharedData.Keys.minuteInterval.rawValue)
        }
    }
    
    var payPeriodSchedule: PayPeriodSchedule {
        get {
            return self.object(forKey: SharedData.Keys.payPeriodSchedule.rawValue) as? PayPeriodSchedule ?? .Weekly
        }
        set(newPayPeriodSchedule) {
            self.set(newPayPeriodSchedule, forKey: SharedData.Keys.payPeriodSchedule.rawValue)
        }
    }
    
    var endOfLastPayPeriod: Date {
        get {
            return self.date(forKey: SharedData.Keys.endOfLastPayPeriod.rawValue) ?? Calendar.current.date(from: DateComponents(year: 2024, month: 07, day: 21))!
        }
        set(newEndOfLastPayPeriod) {
            self.set(newEndOfLastPayPeriod, forKey: SharedData.Keys.endOfLastPayPeriod.rawValue)
        }
    }
    
    var breaks: [BreakEntry]? {
        get {
            guard let text = self.string(forKey: SharedData.Keys.breaks.rawValue) else {
                return nil
            }
            
            return [BreakEntry](rawValue: text)
        }
        set(newBreaks) {
            guard let breaks = newBreaks else {
                self.removeObject(forKey: SharedData.Keys.breaks.rawValue)
                return
            }
            
            self.set(breaks.rawValue, forKey: SharedData.Keys.breaks.rawValue)
        }
    }
    
    var breakStart: Date? {
        get {
            return self.date(forKey: SharedData.Keys.breakStart.rawValue)
        }
        set(newBreakStart) {
            guard let breakStart = newBreakStart else {
                self.removeObject(forKey: SharedData.Keys.breakStart.rawValue)
                return
            }
            
            self.set(breakStart, forKey: SharedData.Keys.breakStart.rawValue)
        }
    }
    
    var notes: String? {
        get {
            return self.string(forKey: SharedData.Keys.notes.rawValue)
        }
        set(newNotes) {
            guard let notes = newNotes else {
                self.removeObject(forKey: SharedData.Keys.notes.rawValue)
                return
            }
            
            self.set(notes, forKey: SharedData.Keys.notes.rawValue)
        }
    }
    
    var clockInDate: Date? {
        get {
            return self.date(forKey: SharedData.Keys.clockInDate.rawValue)
        }
        set(newClockInDate) {
            guard let clockInDate = newClockInDate else {
                self.removeObject(forKey: SharedData.Keys.clockInDate.rawValue)
                return
            }
            self.set(clockInDate, forKey: SharedData.Keys.clockInDate.rawValue)
        }
    }
    
    var clockInState: ClockInState {
        get {
            guard let rawValue = self.string(forKey: SharedData.Keys.clockInState.rawValue) else {
                return .clockedOut
            }
            
            return ClockInState(rawValue: rawValue) ?? .clockedOut
        }
        set(newClockInState) {
            self.set(newClockInState.rawValue, forKey: SharedData.Keys.clockInState.rawValue)
        }
    }
}
