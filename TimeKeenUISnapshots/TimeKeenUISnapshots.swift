import XCTest

struct UIDate {
    let day: String
    let hour: String
    let minute: String
    
    init(day: String, hour: String, minute: String) {
        self.day = day
        self.hour = hour
        self.minute = minute
    }
}

extension XCUIElementQuery {
    func pickDate(_ date: UIDate) {
        element(boundBy: 0).adjust(toPickerWheelValue: date.day)
        element(boundBy: 1).adjust(toPickerWheelValue: date.hour)
        element(boundBy: 2).adjust(toPickerWheelValue: date.minute)
    }
}

extension XCUIApplication {
    func clockIn(at start: UIDate) {
        buttons["ClockInButton"].tap()
        datePickers["ClockInDatePicker"].pickerWheels.pickDate(start)
        buttons["ClockInStartButton"].tap()
    }
    
    func clockOut(at end: UIDate) {
        buttons["ClockOutButton"].tap()
        datePickers["ClockOutDatePicker"].pickerWheels.pickDate(end)
        buttons["ClockOutStopButton"].tap()
    }
    
    func startBreak(at start: UIDate) {
        buttons["StartBreakButton"].tap()
        datePickers["StartBreakDatePicker"].pickerWheels.pickDate(start)
        buttons["StartBreakStartButton"].tap()
    }
    
    func endBreak(at end: UIDate) {
        buttons["EndBreakButton"].tap()
        datePickers["EndBreakDatePicker"].pickerWheels.pickDate(end)
        buttons["EndBreakStopButton"].tap()
    }
    
    func addBreak(from start: UIDate, to end: UIDate) {
        startBreak(at: start)
        endBreak(at: end)
    }
    
    func addTimeEntry(from start: UIDate, to end: UIDate, with breaks: [(UIDate, UIDate)] = [(UIDate, UIDate)]()) {
        clockIn(at: start)
        breaks.forEach { addBreak(from: $0.0, to: $0.1) }
        clockOut(at: end)
    }
    
    func addSomeTimeEntries() {
    }
}

final class TimeKeenUISnapshots: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    @MainActor
    func testTakeSnapshots() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        app.addSomeTimeEntries()
        
        snapshot("01ClockedOut")
        app.clockIn(at: UIDate(day: "Aug 11", hour: "07", minute: "15"))
        snapshot("02ClockedIn")
        app.clockOut(at: UIDate(day: "Aug 11", hour: "09", minute: "45"))
        snapshot("03ClockedOut")
        
        app.buttons["TimeSheetsButton"].tap()
        snapshot("04TimeSheets")
    }
}
