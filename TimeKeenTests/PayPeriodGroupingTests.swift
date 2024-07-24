import XCTest
@testable import TimeKeen

final class PayPeriodGroupingTests: XCTestCase {
  private let formatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    return formatter
  }()
  
  func date(_ string: String) -> Date {
    return formatter.date(from: string)!
  }
  
  @MainActor
  func test_group_byWeeklyEndOnSunday_ShouldGroupByCorrectly() throws {
    let entries = [
      TimeEntry(from: date("2024-07-21 07:30"), to: date("2024-07-21 07:45")),
      TimeEntry(from: date("2024-07-22 07:30"), to: date("2024-07-22 07:45")),
      TimeEntry(from: date("2024-07-28 07:30"), to: date("2024-07-28 07:45")),
      TimeEntry(from: date("2024-07-29 07:30"), to: date("2024-07-29 07:45")),
    ]
    
    let periodEnd = date("2024-07-07 07:00")
    
    let groupedEntries = entries.group(by: .Weekly, ending: periodEnd)
    
    XCTAssertEqual(groupedEntries.keys.count, 3)
  }
  
  @MainActor
  func test_group_byWeeklyEndOnFriday_ShouldGroupByCorrectly() throws {
    let entries = [
      TimeEntry(from: date("2024-07-19 07:30"), to: date("2024-07-19 07:45")),
      TimeEntry(from: date("2024-07-20 07:30"), to: date("2024-07-20 07:45")),
      TimeEntry(from: date("2024-07-26 07:30"), to: date("2024-07-26 07:45")),
      TimeEntry(from: date("2024-07-27 07:30"), to: date("2024-07-27 07:45")),
    ]
    
    let periodEnd = date("2024-07-05 07:00")
    
    let groupedEntries = entries.group(by: .Weekly, ending: periodEnd)
    
    XCTAssertEqual(groupedEntries.keys.count, 3)
  }
  
  @MainActor
  func test_group_byBiweeklyEndOnSunday_ShouldGroupByCorrectly() throws {
    let entries = [
      TimeEntry(from: date("2024-07-21 07:30"), to: date("2024-07-21 07:45")),
      TimeEntry(from: date("2024-07-22 07:30"), to: date("2024-07-22 07:45")),
      TimeEntry(from: date("2024-08-04 07:30"), to: date("2024-08-04 07:45")),
      TimeEntry(from: date("2024-08-05 07:30"), to: date("2024-08-05 07:45")),
    ]
    
    let periodEnd = date("2024-07-07 07:00")
    
    let groupedEntries = entries.group(by: .Biweekly, ending: periodEnd)
    
    XCTAssertEqual(groupedEntries.keys.count, 3)
  }
  
  @MainActor
  func test_group_byBiweeklyEndOnFriday_ShouldGroupByCorrectly() throws {
    let entries = [
      TimeEntry(from: date("2024-07-18 07:30"), to: date("2024-07-18 07:45")),
      TimeEntry(from: date("2024-07-19 07:30"), to: date("2024-07-19 07:45")),
      TimeEntry(from: date("2024-08-02 07:30"), to: date("2024-08-02 07:45")),
      TimeEntry(from: date("2024-08-03 07:30"), to: date("2024-08-03 07:45")),
    ]
    
    let periodEnd = date("2024-07-05 07:00")
    
    let groupedEntries = entries.group(by: .Biweekly, ending: periodEnd)
    
    XCTAssertEqual(groupedEntries.keys.count, 3)
  }
  
  @MainActor
  func test_group_byMonthlyEndOn28_ShouldGroupByCorrectly() throws {
    let entries = [
      TimeEntry(from: date("2024-02-28 07:30"), to: date("2024-02-28 07:45")),
      TimeEntry(from: date("2024-02-29 07:30"), to: date("2024-02-29 07:45")),
      TimeEntry(from: date("2024-03-28 07:30"), to: date("2024-03-28 07:45")),
      TimeEntry(from: date("2024-03-29 07:30"), to: date("2024-03-29 07:45")),
    ]
    
    let periodEnd = date("2023-07-28 07:00")
    
    let groupedEntries = entries.group(by: .Monthly, ending: periodEnd)
    
    XCTAssertEqual(groupedEntries.keys.count, 3)
  }
  
  @MainActor
  func test_group_byEveryFourWeeks_ShouldGroupByCorrectly() throws {
    let entries = [
      TimeEntry(from: date("2024-08-04 07:30"), to: date("2024-08-04 07:45")),
      TimeEntry(from: date("2024-08-05 07:30"), to: date("2024-08-05 07:45")),
      TimeEntry(from: date("2024-09-01 07:30"), to: date("2024-09-01 07:45")),
      TimeEntry(from: date("2024-09-02 07:30"), to: date("2024-09-02 07:45")),
    ]
    
    let periodEnd = date("2024-07-07 07:00")
    
    let groupedEntries = entries.group(by: .EveryFourWeeks, ending: periodEnd)
    
    XCTAssertEqual(groupedEntries.keys.count, 3)
  }
  
  @MainActor
  func test_group_byFirstAndSixteenth_ShouldGroupByCorrectly() throws {
    let entries = [
      TimeEntry(from: date("2024-07-31 07:30"), to: date("2024-07-31 07:45")),
      TimeEntry(from: date("2024-08-01 07:30"), to: date("2024-08-01 07:45")),
      TimeEntry(from: date("2024-08-15 07:30"), to: date("2024-08-15 07:45")),
      TimeEntry(from: date("2024-08-16 07:30"), to: date("2024-08-16 07:45")),
      TimeEntry(from: date("2024-08-31 07:30"), to: date("2024-08-31 07:45")),
      TimeEntry(from: date("2024-09-01 07:30"), to: date("2024-09-01 07:45")),
    ]
    
    let periodEnd = date("2024-07-07 07:00")
    
    let groupedEntries = entries.group(by: .EveryFourWeeks, ending: periodEnd)
    
    XCTAssertEqual(groupedEntries.keys.count, 3)
  }
 }
