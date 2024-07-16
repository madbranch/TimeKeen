import XCTest
import SwiftData
@testable import TimeKeen

final class CurrentTimeEntryViewModelTests: XCTestCase {
  
  @MainActor
  func test_Init_WithDefault_ShouldNotBeStarted() throws {
    let container = try createContainer()
    let currentTimeEntry = CurrentTimeEntryViewModel(context: container.mainContext)
    XCTAssertEqual(ClockInState.ClockedOut, currentTimeEntry.clockInState)
  }
  
  @MainActor
  func test_Init_WithStartDate_ShouldBeClockedIn() throws {
    let container = try createContainer()
    let date = CurrentTimeEntryViewModelTests.createSomeValidStartDate()
    let currentTimeEntry = CurrentTimeEntryViewModel(context: container.mainContext, clockedInAt: date)
    XCTAssertEqual(ClockInState.ClockedIn, currentTimeEntry.clockInState)
    XCTAssertEqual(date, currentTimeEntry.clockInDate)
  }
  
  @MainActor
  func test_ClockOut_WithStartNil_ShouldReturnNotStarted() throws {
    let container = try createContainer()
    let currentTimeEntry = CurrentTimeEntryViewModel(context: container.mainContext)
    let result: Result<TimeEntry, ClockOutError> = currentTimeEntry.clockOut(at: CurrentTimeEntryViewModelTests.createSomeValidStartDate())
    XCTAssertEqual(.failure(ClockOutError.notClockedIn), result)
  }
  
  @MainActor
  func test_ClockOut_WithEndEqualToStart_ShouldReturnStartAndEndEqualError() throws {
    let container = try createContainer()
    let currentTimeEntry = CurrentTimeEntryViewModel(context: container.mainContext)
    let start = CurrentTimeEntryViewModelTests.createSomeValidStartDate()
    currentTimeEntry.clockIn(at: start)
    let end = start
    XCTAssertEqual(.failure(.startAndEndEqual), currentTimeEntry.clockOut(at: end))
  }
  
  @MainActor
  func test_ClockOut_WithValidStart_ShouldReturnTimeEntryAndStartShouldBeNil() throws {
    let container = try createContainer()
    let currentTimeEntry = CurrentTimeEntryViewModel(context: container.mainContext)
    let start = CurrentTimeEntryViewModelTests.createSomeValidStartDate()
    currentTimeEntry.clockIn(at: start)
    let end = CurrentTimeEntryViewModelTests.createSomeValidEndDate()
    XCTAssertNoThrow(try currentTimeEntry.clockOut(at: end).get())
    XCTAssertEqual(ClockInState.ClockedOut, currentTimeEntry.clockInState)
  }
  
  private static func createSomeValidStartDate() -> Date {
    var dateComponents = DateComponents()
    dateComponents.year = 2022
    dateComponents.month = 12
    dateComponents.day = 31
    dateComponents.timeZone = TimeZone(abbreviation: "EST")
    dateComponents.hour = 9
    dateComponents.minute = 30
    let calendar = Calendar(identifier: .gregorian)
    return calendar.date(from: dateComponents)!
  }
  
  private static func createSomeValidEndDate() -> Date {
    var dateComponents = DateComponents()
    dateComponents.year = 2022
    dateComponents.month = 12
    dateComponents.day = 31
    dateComponents.timeZone = TimeZone(abbreviation: "EST")
    dateComponents.hour = 9
    dateComponents.minute = 45
    let calendar = Calendar(identifier: .gregorian)
    return calendar.date(from: dateComponents)!
  }
  
  private func createContainer() throws -> ModelContainer {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    return try ModelContainer(for: TimeEntry.self, configurations: configuration )
  }
}
