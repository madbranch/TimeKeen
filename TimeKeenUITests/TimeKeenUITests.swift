import XCTest

final class TimeKeenUITests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testClockInButton() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments.append("clear")
        app.launch()
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let clockInButton = app.buttons["ClockInButton"]
        clockInButton.tap()
        
        let clockInStartButton = app.buttons["ClockInStartButton"]
        clockInStartButton.tap()
        
        let clockInDurationText = app.staticTexts["ClockInDurationText"]
        XCTAssertTrue(clockInDurationText.exists)
    }
}
