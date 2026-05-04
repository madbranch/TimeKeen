import Foundation
@preconcurrency import WatchConnectivity

enum WatchClockOutClientError: LocalizedError {
    case unsupported
    case phoneUnavailable
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .unsupported:
            "Watch connectivity is unavailable on this device."
        case .phoneUnavailable:
            "Your iPhone needs to be nearby and the TimeKeen app must be available."
        case .invalidResponse:
            "Clock out failed."
        }
    }
}

final class WatchClockOutClient: NSObject, WCSessionDelegate {
    private let messageActionKey = "action"
    private let messageDateKey = "timestamp"
    private let clockOutAction = "clockOut"

    @MainActor
    func activate() {
        guard WCSession.isSupported() else {
            return
        }

        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    @MainActor
    func clockOut(at date: Date) async throws -> String {
        guard WCSession.isSupported() else {
            throw WatchClockOutClientError.unsupported
        }

        let session = WCSession.default
        guard session.isReachable else {
            throw WatchClockOutClientError.phoneUnavailable
        }

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            session.sendMessage(
                [
                    messageActionKey: clockOutAction,
                    messageDateKey: date.timeIntervalSince1970
                ],
                replyHandler: { response in
                    guard let success = response["success"] as? Bool, let message = response["message"] as? String else {
                        continuation.resume(throwing: WatchClockOutClientError.invalidResponse)
                        return
                    }

                    guard success else {
                        continuation.resume(throwing: NSError(domain: "TimeKeenWatch", code: 1, userInfo: [NSLocalizedDescriptionKey: message]))
                        return
                    }

                    continuation.resume(returning: message)
                },
                errorHandler: { error in
                    continuation.resume(throwing: error)
                }
            )
        }
    }

    nonisolated func sessionReachabilityDidChange(_ session: WCSession) {}

    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}
