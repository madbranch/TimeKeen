import XCTest

@MainActor
struct UIDate {
    let day: String
    let hour: String
    let minute: String
    
    init(year: Int, month: Int, day: Int, hour: Int, minute: Int) {
        guard let date = Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute)) else {
            fatalError("Failed to create date from components.")
        }
        let locale = Locale(identifier: Snapshot.currentLocale)
        self.day = Formatting.getYearlessDateFormatter(locale: locale).string(from: date)
        self.hour = String(format: "%02d", Calendar.current.component(.hour, from: date))
        self.minute = Formatting.getMinuteFormatter(locale: locale).string(from: date)
    }
}

extension XCUIElementQuery {
    func pickDate(_ date: UIDate) {
        let dayElement = element(boundBy: 0)
        dayElement.adjust(toPickerWheelValue: date.day)
        
        let hourElement = element(boundBy: 1)
        hourElement.adjust(toPickerWheelValue: date.hour)
        
        let minuteElement = element(boundBy: 2)
        minuteElement.adjust(toPickerWheelValue: date.minute)
    }
    
    func pickDate(at values: [(Int, String)]) {
        for value in values {
            let pickerElement = element(boundBy: value.0)
            pickerElement.adjust(toPickerWheelValue: value.1)
        }
    }
}

extension XCUIElement {
    func pickDate(_ date: UIDate) {
        pickerWheels.pickDate(date)
    }
    
    func pickDate(at values: [(Int, String)]) {
        pickerWheels.pickDate(at: values)
    }
}

extension XCUIApplication {
    func clockIn(at start: UIDate) {
        buttons["ClockInButton"].tap()
        datePickers["ClockInDatePicker"].pickDate(start)
        buttons["ClockInStartButton"].tap()
    }
    
    func clockIn(values: (Int, String)...) {
        buttons["ClockInButton"].tap()
        datePickers["ClockInDatePicker"].pickDate(at: values)
        buttons["ClockInStartButton"].tap()
    }
    
    func clockOut(at end: UIDate) {
        buttons["ClockOutButton"].tap()
        datePickers["ClockOutDatePicker"].pickDate(end)
        buttons["ClockOutStopButton"].tap()
    }
    
    func clockOut(values: (Int, String)...) {
        buttons["ClockOutButton"].tap()
        datePickers["ClockOutDatePicker"].pickDate(at: values)
        buttons["ClockOutStopButton"].tap()
    }

    func startBreak(at start: UIDate) {
        buttons["StartBreakButton"].tap()
        datePickers["StartBreakDatePicker"].pickDate(start)
        buttons["StartBreakStartButton"].tap()
    }
    
    func endBreak(at end: UIDate) {
        buttons["EndBreakButton"].tap()
        datePickers["EndBreakDatePicker"].pickDate(end)
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
        app.clockIn(values: (1, "07"), (2, "15"))
        snapshot("02ClockedIn")
        app.clockOut(values: (1, "09"), (2, "45"))
        snapshot("03ClockedOut")
        
        app.staticTexts["OnTheClockViewButton"].tap()
        snapshot("04CurrentTimeSheet")
        
        let startDate = Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 9))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 15))!

        let locale = Locale(identifier: Snapshot.currentLocale)
        let yearlessDateFormatter = Formatting.getYearlessDateFormatter(locale: locale)
        app.navigationBars["\(yearlessDateFormatter.string(from: startDate)) - \(yearlessDateFormatter.string(from: endDate))"].buttons.element(boundBy: 0).tap()

        app.buttons["TimeSheetsButton"].tap()
        snapshot("05TimeSheets")
    }
}
