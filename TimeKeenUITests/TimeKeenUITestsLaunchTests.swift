//
//  TimeKeenUITestsLaunchTests.swift
//  TimeKeenUITests
//
//  Created by Adam Labranche on 2022-12-31.
//

import XCTest

final class TimeKeenUITestsLaunchTests: XCTestCase {
    
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    
    let app = XCUIApplication()
    app/*@START_MENU_TOKEN@*/.buttons["ClockInButton"]/*[[".buttons[\"Clock In...\"]",".buttons[\"ClockInButton\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    
    let clockindatepickerDatePicker = app.datePickers["ClockInDatePicker"]
    clockindatepickerDatePicker/*@START_MENU_TOKEN@*/.pickerWheels["Today"]/*[[".pickers.pickerWheels[\"Today\"]",".pickerWheels[\"Today\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    clockindatepickerDatePicker/*@START_MENU_TOKEN@*/.pickerWheels["45 minutes"]/*[[".pickers.pickerWheels[\"45 minutes\"]",".pickerWheels[\"45 minutes\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    app.navigationBars["Clock In"]/*@START_MENU_TOKEN@*/.buttons["ClockInStartButton"]/*[[".otherElements[\"Start\"]",".buttons[\"Start\"]",".buttons[\"ClockInStartButton\"]",".otherElements[\"ClockInStartButton\"]"],[[[-1,2],[-1,1],[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app
        
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
