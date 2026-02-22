import SwiftUI
import SwiftData
import WidgetKit

struct CurrentTimeEntryView: View {
    var quickActionProvider: QuickActionProvider
    
    @Environment(\.modelContext) private var context
    @Environment(\.dateProvider) private var dateProvider
    @State private var timeClockManager = TimeClockManager()
    
    @State private var payPeriod: ClosedRange<Date> = Date.now...Date.now
    @State private var isClockingIn = false
    @State private var isClockingOut = false
    @State private var isStartingBreak = false
    @State private var isEndingBreak = false
    
    @AppStorage(SharedData.Keys.payPeriodSchedule.rawValue, store: SharedData.userDefaults) var payPeriodSchedule = PayPeriodSchedule.Weekly
    @AppStorage(SharedData.Keys.endOfLastPayPeriod.rawValue, store: SharedData.userDefaults) var endOfLastPayPeriod = Calendar.current.date(from: DateComponents(year: 2024, month: 07, day: 21))!
    @FocusState private var isEditingNotes: Bool
    @State private var isOntheClockTimeVisible = true
    private let navigate: (ClosedRange<Date>) -> Void
    private static let bigButtonPadding: CGFloat = 35
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(quickActionProvider: QuickActionProvider, navigate: @escaping (ClosedRange<Date>) -> Void) {
        self.quickActionProvider = quickActionProvider
        self.navigate = navigate
    }
    
    var body: some View {
        VStack {
            switch timeClockManager.clockInState {
            case .clockedOut:
                Button {
                    timeClockManager.clockInDate = timeClockManager.getRoundedNow()
                    timeClockManager.notes = ""
                    isClockingIn = true
                } label: {
                    Text("Clock In...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                }
                .buttonStyle(TimeClockButton())
                .padding(CurrentTimeEntryView.bigButtonPadding)
                .accessibilityIdentifier("ClockInButton")
            case .clockedInWorking, .clockedInTakingABreak:
                Text(Formatting.timeIntervalFormatter.string(from: max(timeClockManager.clockInDuration, TimeInterval())) ?? "")
                    .contentTransition(.numericText(value: timeClockManager.clockInDuration))
                    .foregroundStyle((timeClockManager.clockInState == .clockedInTakingABreak || timeClockManager.clockInDuration < 0) ? .secondary : .primary)
                    .font(.system(size: 1000, design: .rounded))
                    .minimumScaleFactor(0.005)
                    .lineLimit(1)
                    .frame(maxHeight: 300)
                    .accessibilityIdentifier("ClockInDurationText")
                if timeClockManager.clockInState == .clockedInTakingABreak {
                    Text("Started Break at \(Formatting.startEndFormatter.string(from: timeClockManager.breakStart))")
                }
                Text(timeClockManager.sinceClockIn < 0 ? "Clocking in at \(Formatting.startEndFormatter.string(from: timeClockManager.clockInDate))..." : "Clocked in at \(Formatting.startEndFormatter.string(from: timeClockManager.clockInDate))")
                    .foregroundStyle(timeClockManager.clockInState == .clockedInTakingABreak ? .secondary : .primary)
                    .padding()
                HStack {
                    if timeClockManager.clockInState == .clockedInWorking {
                        Button {
                            isStartingBreak = timeClockManager.startTakingBreak()
                        } label: {
                            Image(systemName: "pause.fill")
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .accessibilityIdentifier("StartBreakButton")
                        .buttonStyle(TimeClockButton())
                        .padding()
                        Button {
                            isClockingOut = timeClockManager.startClockingOut()
                        } label: {
                            Image(systemName: "stop.fill")
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .accessibilityIdentifier("ClockOutButton")
                        .buttonStyle(TimeClockButton())
                        .padding()
                    } else if timeClockManager.clockInState == .clockedInTakingABreak {
                        Button {
                            isEndingBreak = timeClockManager.startEndingBreak()
                        } label: {
                            Image(systemName: "play.fill")
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .accessibilityIdentifier("EndBreakButton")
                        .buttonStyle(TimeClockButton())
                        .padding(CurrentTimeEntryView.bigButtonPadding)
                    }
                }
                TextField("Notes", text: $timeClockManager.notes)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                    .focused($isEditingNotes)
                    .onChange(of: isEditingNotes) { _, newValue in
                        withAnimation {
                            isOntheClockTimeVisible = !newValue
                        }
                    }
            }
            if isOntheClockTimeVisible {
                TimeSheetOnTheClockView(payPeriod: payPeriod, clockInDuration: timeClockManager.clockInDuration)
                    .padding()
                    .onTapGesture {
                        navigate(payPeriod)
                    }
                    .accessibilityIdentifier("OnTheClockViewButton")
            }
        }
        .onChange(of: quickActionProvider.quickAction) { _, _ in
            handleQuickAction()
        }
        .sensoryFeedback(trigger: timeClockManager.clockInState) { old, new in
            return switch new {
            case .clockedOut: .success
            case .clockedInWorking, .clockedInTakingABreak: old == .clockedOut ? .impact : nil
            }
        }
        .onAppear {
            timeClockManager.dateProvider = dateProvider
            timeClockManager.modelContextInsert = { context.insert($0) }
            timeClockManager.updateClockInDuration()
            // We make sure not to rely on waiting for the first time tick.
            updatePayPeriod()
            handleQuickAction()
        }
        .onReceive(timer) { _ in
            withAnimation {
                updatePayPeriod()
                timeClockManager.updateClockInDuration()
            }
        }
        .sheet(isPresented: $isClockingIn) { [minuteInterval = timeClockManager.minuteInterval] in
            NavigationStack {
                IntervalDatePicker(selection: $timeClockManager.clockInDate, minuteInterval: minuteInterval, displayedComponents: [.date, .hourAndMinute], style: .wheels)
                    .accessibilityIdentifier("ClockInDatePicker")
                    .navigationTitle("Clock In")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Start") {
                                timeClockManager.clockIn(at: timeClockManager.clockInDate)
                                isClockingIn = false
                            }
                            .accessibilityIdentifier("ClockInStartButton")
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel", role: .cancel) {
                                isClockingIn = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $isClockingOut) { [minClockOutDate = timeClockManager.minClockOutDate, minuteInterval = timeClockManager.minuteInterval] in
            NavigationStack {
                IntervalDatePicker(selection: $timeClockManager.clockOutDate, minuteInterval: minuteInterval, in: minClockOutDate..., displayedComponents: [.date, .hourAndMinute], style: .wheels)
                    .accessibilityIdentifier("ClockOutDatePicker")
                    .navigationTitle("Clock Out")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Stop") {
                                timeClockManager.clockOut(at: timeClockManager.clockOutDate, notes: timeClockManager.notes)
                                isClockingOut = false
                            }
                            .accessibilityIdentifier("ClockOutStopButton")
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel", role: .cancel) {
                                isClockingOut = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $isStartingBreak) { [minBreakStart = timeClockManager.minBreakStart, minuteInterval = timeClockManager.minuteInterval] in
            NavigationStack {
                IntervalDatePicker(selection: $timeClockManager.breakStart, minuteInterval: minuteInterval, in: minBreakStart..., displayedComponents: [.date, .hourAndMinute], style: .wheels)
                    .accessibilityIdentifier("StartBreakDatePicker")
                    .navigationTitle("Take a Break")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Pause") {
                                timeClockManager.startBreak(at: timeClockManager.breakStart)
                                isStartingBreak = false
                            }
                            .accessibilityIdentifier("StartBreakStartButton")
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel", role: .cancel) {
                                isStartingBreak = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $isEndingBreak) { [minBreakEndDate = timeClockManager.minBreakEndDate, minuteInterval = timeClockManager.minuteInterval] in
            NavigationStack {
                IntervalDatePicker(selection: $timeClockManager.breakEnd, minuteInterval: minuteInterval, in: minBreakEndDate..., displayedComponents: [.date, .hourAndMinute], style: .wheels)
                    .accessibilityIdentifier("EndBreakDatePicker")
                    .navigationTitle("Go back to work")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Resume") {
                                timeClockManager.endBreak(at: timeClockManager.breakEnd)
                                isEndingBreak = false
                            }
                            .accessibilityIdentifier("EndBreakStopButton")
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel", role: .cancel) {
                                isEndingBreak = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium])
        }
    }
    
    func handleQuickAction() {
        guard let quickAction = quickActionProvider.quickAction else {
            return
        }
        
        timeClockManager.handle(quickAction)
        quickActionProvider.quickAction = nil
    }
    
    private func updatePayPeriod() {
        payPeriod = dateProvider.now.getPayPeriod(schedule: payPeriodSchedule, periodEnd: endOfLastPayPeriod)
    }
}
