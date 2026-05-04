import XCTest
@testable import TimeKeen

final class TimeKeenTests: XCTestCase {
    private var suiteName: String!
    private var userDefaults: UserDefaults!

    override func setUpWithError() throws {
        suiteName = "TimeKeenTests-\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults.minuteInterval = 15
    }

    override func tearDownWithError() throws {
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        suiteName = nil
    }

    func testClockInRoundsAndUpdatesState() throws {
        let service = makeService()
        let sourceDate = makeDate(hour: 9, minute: 8)

        let result = try XCTUnwrap(try? service.clockIn(at: sourceDate).get())

        XCTAssertEqual(result.effectiveDate, makeDate(hour: 9, minute: 15))
        XCTAssertEqual(userDefaults.clockInState, .clockedInWorking)
        XCTAssertEqual(userDefaults.clockInDate, makeDate(hour: 9, minute: 15))
        XCTAssertEqual(result.snapshot.clockInState, .clockedInWorking)
        XCTAssertTrue(result.snapshot.canClockOut)
    }

    func testClockInFailsWhenAlreadyClockedIn() {
        userDefaults.clockInState = .clockedInWorking
        userDefaults.clockInDate = makeDate(hour: 9, minute: 0)
        let service = makeService()

        let result = service.clockIn(at: makeDate(hour: 9, minute: 10))

        switch result {
        case .success:
            XCTFail("Expected clock in to fail when already clocked in.")
        case let .failure(error):
            XCTAssertEqual(error, .alreadyClockedIn)
        }
    }

    func testClockOutPersistsEntryAndClearsState() throws {
        userDefaults.clockInState = .clockedInWorking
        userDefaults.clockInDate = makeDate(hour: 9, minute: 0)
        userDefaults.notes = "Shift"
        var persistedEntry: TimeEntry?
        let service = makeService { persistedEntry = $0 }

        let result = try XCTUnwrap(try? service.clockOut(at: makeDate(hour: 17, minute: 2), notes: nil).get())

        XCTAssertEqual(result.effectiveDate, makeDate(hour: 17, minute: 0))
        XCTAssertEqual(userDefaults.clockInState, .clockedOut)
        XCTAssertTrue(userDefaults.breaks?.isEmpty ?? true)
        XCTAssertNotNil(persistedEntry)
        XCTAssertEqual(persistedEntry?.start, makeDate(hour: 9, minute: 0))
        XCTAssertEqual(persistedEntry?.end, makeDate(hour: 17, minute: 0))
        XCTAssertEqual(persistedEntry?.notes, "Shift")
        XCTAssertFalse(result.snapshot.canClockOut)
    }

    func testClockOutFailsWhenNotWorking() {
        userDefaults.clockInState = .clockedOut
        let service = makeService()

        let result = service.clockOut(at: makeDate(hour: 17, minute: 0), notes: nil)

        switch result {
        case .success:
            XCTFail("Expected clock out to fail when not working.")
        case let .failure(error):
            XCTAssertEqual(error, .notWorking)
        }
    }

    private func makeService(persistClockOut: TimeClockActionService.ClockOutPersistence? = nil) -> TimeClockActionService {
        TimeClockActionService(userDefaults: userDefaults, persistClockOut: persistClockOut)
    }

    private func makeDate(hour: Int, minute: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 9, hour: hour, minute: minute))!
    }
}
