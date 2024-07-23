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
  func test_getGroupByMethod_WeeklyEndOnSunday_ShouldGroupByCorrectly() throws {
    let entries = [
      // Sunday
      TimeEntry(from: date("2024-07-21 07:30"), to: date("2024-07-21 07:45")),
      // Monday
      TimeEntry(from: date("2024-07-22 07:30"), to: date("2024-07-22 07:45")),
      // Sunday
      TimeEntry(from: date("2024-07-28 07:30"), to: date("2024-07-28 07:45")),
      // Monday
      TimeEntry(from: date("2024-07-29 07:30"), to: date("2024-07-29 07:45")),
    ]
    
    // Sunday
    let periodEnd = date("2024-07-07 07:00")
    
    let groupedEntries = entries.group(by: .Weekly, ending: periodEnd)
    
    XCTAssertEqual(groupedEntries.keys.count, 3)
  }
  
  @MainActor
  func test_getGroupByMethod_WeeklyEndOnFriday_ShouldGroupByCorrectly() throws {
    let entries = [
      // Friday
      TimeEntry(from: date("2024-07-19 07:30"), to: date("2024-07-19 07:45")),
      // Saturday
      TimeEntry(from: date("2024-07-20 07:30"), to: date("2024-07-20 07:45")),
      // Friday
      TimeEntry(from: date("2024-07-26 07:30"), to: date("2024-07-26 07:45")),
      // Saturday
      TimeEntry(from: date("2024-07-27 07:30"), to: date("2024-07-27 07:45")),
    ]
    
    // Friday
    let periodEnd = date("2024-07-05 07:00")
    
    let groupedEntries = entries.group(by: .Weekly, ending: periodEnd)
    
    XCTAssertEqual(groupedEntries.keys.count, 3)
  }
}
