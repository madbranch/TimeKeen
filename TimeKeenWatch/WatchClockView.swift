import SwiftUI

@MainActor
@Observable
final class WatchTimeClockViewModel {
    private let actionService = TimeClockActionService()
    private let clockOutClient = WatchClockOutClient()

    var isProcessing = false
    var errorMessage: String?

    init() {
        clockOutClient.activate()
    }

    func snapshot(now: Date) -> TimeClockSnapshot {
        actionService.loadSnapshot(now: now)
    }

    func clockIn() {
        switch actionService.clockInNow(now: .now) {
        case .success:
            errorMessage = nil
        case let .failure(error):
            errorMessage = error.localizedDescription
        }
    }

    func clockOut() async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            _ = try await clockOutClient.clockOut(at: actionService.roundedDate(for: .now))
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }
}

struct WatchClockView: View {
    @State private var viewModel = WatchTimeClockViewModel()

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let snapshot = viewModel.snapshot(now: context.date)

            VStack(spacing: 10) {
                if snapshot.clockInState == .clockedOut {
                    Spacer(minLength: 0)
                    Button("Clock In") {
                        viewModel.clockIn()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isProcessing || !snapshot.canClockIn)
                    Spacer(minLength: 0)
                } else {
                    Text(Formatting.timeIntervalFormatter.string(from: max(snapshot.clockInDuration, .zero)) ?? "00:00")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .monospacedDigit()

                    if let clockInDate = snapshot.clockInDate {
                        Text("In at \(Formatting.startEndFormatter.string(from: clockInDate))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Button(viewModel.isProcessing ? "Clocking Out..." : "Clock Out") {
                        Task {
                            await viewModel.clockOut()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isProcessing || !snapshot.canClockOut)

                    if viewModel.isProcessing {
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                }
            }
            .scenePadding()
        }
        .alert("Action Failed", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button("OK", role: .cancel) {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
