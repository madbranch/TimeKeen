import XCTest
import CoreData
@testable import TimeKeen

final class CurrentTimeEntryViewModelTests: XCTestCase {
  
  func test_Init_WithDefault_ShouldNotBeStarted() throws {
    let persistenceController = PersistenceController(inMemory: true)
    let currentTimeEntry = CurrentTimeEntryViewModel(context: persistenceController.container.viewContext)
    XCTAssertNil(currentTimeEntry.start)
  }
  
  func test_SetStartWithValidDate_ShouldContainSetValue() throws {
    let persistenceController = PersistenceController(inMemory: true)
    let currentTimeEntry = CurrentTimeEntryViewModel(context: persistenceController.container.viewContext)
    let date = CurrentTimeEntryViewModelTests.createSomeValidStartDate()
    currentTimeEntry.start = date
    XCTAssertEqual(date, currentTimeEntry.start)
  }
  
  func test_ClockOut_WithStartNil_ShouldReturnNotStarted() throws {
    let persistenceController = PersistenceController(inMemory: true)
    let currentTimeEntry = CurrentTimeEntryViewModel(context: persistenceController.container.viewContext)
    let result: Result<TimeEntry, ClockOutError> = currentTimeEntry.clockOut(at: CurrentTimeEntryViewModelTests.createSomeValidStartDate())
    XCTAssertEqual(.failure(ClockOutError.notStarted), result)
  }
  
  func test_ClockOut_WithEndEqualToStart_ShouldReturnStartAndEndEqualError() throws {
    let persistenceController = PersistenceController(inMemory: true)
    let currentTimeEntry = CurrentTimeEntryViewModel(context: persistenceController.container.viewContext)
    let start = CurrentTimeEntryViewModelTests.createSomeValidStartDate()
    currentTimeEntry.start = start
    let end = start
    XCTAssertEqual(.failure(.startAndEndEqual), currentTimeEntry.clockOut(at: end))
  }
  
  func test_ClockOut_WithValidStart_ShouldReturnTimeEntryAndStartShouldBeNil() throws {
    let persistenceController = PersistenceController(inMemory: true)
    let currentTimeEntry = CurrentTimeEntryViewModel(context: persistenceController.container.viewContext)
    let start = CurrentTimeEntryViewModelTests.createSomeValidStartDate()
    currentTimeEntry.start = start
    let end = CurrentTimeEntryViewModelTests.createSomeValidEndDate()
    XCTAssertNoThrow(try currentTimeEntry.clockOut(at: end).get())
    XCTAssertNil(currentTimeEntry.start)
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
}
