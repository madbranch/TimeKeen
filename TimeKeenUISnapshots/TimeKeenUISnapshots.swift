import XCTest

final class TimeKeenUISnapshots: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    @MainActor
    func testTakeSnapshots() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        snapshot("01ClockedOut")
        let clockInButton = app.buttons["ClockInButton"]
        clockInButton.tap()
        
        let clockInDatePicker = app.datePickers["ClockInDatePicker"]
        XCTAssertTrue(clockInDatePicker.exists)
        let clockInDatePickerWheels = clockInDatePicker.pickerWheels
        clockInDatePickerWheels.element(boundBy: 0).adjust(toPickerWheelValue: "Aug 11")
        clockInDatePickerWheels.element(boundBy: 1).adjust(toPickerWheelValue: "07")
        clockInDatePickerWheels.element(boundBy: 2).adjust(toPickerWheelValue: "15")

        let clockInStartButton = app.buttons["ClockInStartButton"]
        clockInStartButton.tap()
        
        let clockInDurationText = app.staticTexts["ClockInDurationText"]
        XCTAssertTrue(clockInDurationText.exists)
        
        snapshot("02ClockedIn")
    }
}
