import Foundation
import SwiftUI

protocol DateProvider: Sendable {
    var now: Date { get }
}

final class RealDateProvider: DateProvider {
    var now: Date {
        Date.now
    }
}

final class FakeDateProvider: DateProvider {
    private let fakeNow: Date = {
        let dateComponents = DateComponents(year: 2024, month: 8, day: 11, hour: 9, minute: 41)
        return Calendar.current.date(from: dateComponents)!
    }()
    
    var now: Date {
        fakeNow
    }
}

private struct DateProviderKey: EnvironmentKey {
    static let defaultValue: DateProvider = RealDateProvider()
}

extension EnvironmentValues {
    var dateProvider: DateProvider {
        get { self[DateProviderKey.self] }
        set { self[DateProviderKey.self] = newValue }
    }
}

extension View {
    func dateProvider(_ dateProvider: DateProvider) -> some View {
        environment(\.dateProvider, dateProvider)
    }
}
