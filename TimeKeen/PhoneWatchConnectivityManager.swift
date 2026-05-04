import Foundation
import SwiftData
@preconcurrency import WatchConnectivity

final class PhoneWatchConnectivityManager: NSObject, WCSessionDelegate {
    nonisolated(unsafe) static let shared = PhoneWatchConnectivityManager()

    private let messageActionKey = "action"
    private let messageDateKey = "timestamp"
    private let clockOutAction = "clockOut"
    private var modelContainer: ModelContainer?

    private override init() {
        super.init()
    }

    func configure(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func activate() {
        guard WCSession.isSupported() else {
            return
        }

        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        guard
            let action = message[messageActionKey] as? String,
            action == clockOutAction,
            let timestamp = message[messageDateKey] as? TimeInterval
        else {
            replyHandler(["success": false, "message": "Invalid request."])
            return
        }

        let modelContainer = self.modelContainer
        let response: (Bool, String)
        if Thread.isMainThread {
            response = MainActor.assumeIsolated {
                Self.handleClockOutRequest(timestamp: timestamp, modelContainer: modelContainer)
            }
        } else {
            response = DispatchQueue.main.sync {
                MainActor.assumeIsolated {
                    Self.handleClockOutRequest(timestamp: timestamp, modelContainer: modelContainer)
                }
            }
        }

        replyHandler([
            "success": response.0,
            "message": response.1
        ])
    }

    @MainActor
    private static func handleClockOutRequest(timestamp: TimeInterval, modelContainer: ModelContainer?) -> (Bool, String) {
        guard let modelContainer = modelContainer else {
            return (false, "Phone app is not ready.")
        }

        let service = TimeClockActionService(
            persistClockOut: { timeEntry in
                modelContainer.mainContext.insert(timeEntry)
                try modelContainer.mainContext.save()
            },
            reloadWidgets: TimeClockManager.reloadWidgets
        )

        switch service.clockOut(at: Date(timeIntervalSince1970: timestamp), notes: SharedData.userDefaults?.notes) {
        case let .success(result):
            return (true, "Clocked out at \(Formatting.startEndFormatter.string(from: result.effectiveDate)).")
        case let .failure(error):
            return (false, error.localizedDescription)
        }
    }

    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
