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
  func test_getGroupByMethod_WeeklyStartOnMonday_ShouldGroupByCorrectly() throws {
    let entries = [
      // Sunday
      TimeEntry(from: date("2024-07-21 07:30"), to: date("2024-07-21 07:45")),
      // Monday
      TimeEntry(from: date("2024-07-22 07:30"), to: date("2024-07-22 07:45")),
    ]
    
    // Sunday
    let periodEnd = date("2024-07-07 07:00")
    
    let groupedEntries = entries.group(by: .Weekly, ending: periodEnd)
    
    XCTAssertEqual(groupedEntries.keys.count, 2)
  }
}
