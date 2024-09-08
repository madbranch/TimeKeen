import SwiftUI
import SwiftData

struct CurrentTimeEntryView: View {
    var quickActionProvider: QuickActionProvider
    
    @AppStorage(SharedData.Keys.minuteInterval.rawValue, store: SharedData.userDefaults) var minuteInterval = 15 {
        didSet {
            UIDatePicker.appearance().minuteInterval = minuteInterval
        }
    }
    
    @Environment(\.modelContext) private var context
    @Environment(\.dateProvider) private var dateProvider
    @AppStorage(SharedData.Keys.clockInState.rawValue, store: SharedData.userDefaults) var clockInState = ClockInState.clockedOut
    @State private var clockInDuration: TimeInterval = .zero
    @State private var sinceClockIn: TimeInterval = .zero
    @State private var payPeriod: ClosedRange<Date> = Date.now...Date.now
    @State private var isClockingIn = false
    @State private var isClockingOut = false
    @AppStorage(SharedData.Keys.clockInDate.rawValue, store: SharedData.userDefaults) var clockInDate = Date.now
    @State private var clockOutDate = Date.now
    @State private var minClockOutDate = Date.now
    @AppStorage(SharedData.Keys.notes.rawValue, store: SharedData.userDefaults) private var notes = ""
    @State private var isStartingBreak = false
    @State private var isEndingBreak = false
    @State private var minBreakStart = Date.now
    @AppStorage(SharedData.Keys.breakStart.rawValue, store: SharedData.userDefaults) var breakStart = Date.now
    @State private var breakEnd = Date.now
    @State private var minBreakEndDate = Date.now
    @AppStorage(SharedData.Keys.breaks.rawValue, store: SharedData.userDefaults) var breaks = [BreakEntry]()
    @AppStorage(SharedData.Keys.payPeriodSchedule.rawValue, store: SharedData.userDefaults) var payPeriodSchedule = PayPeriodSchedule.Weekly
    @AppStorage(SharedData.Keys.endOfLastPayPeriod.rawValue, store: SharedData.userDefaults) var endOfLastPayPeriod = Calendar.current.date(from: DateComponents(year: 2024, month: 07, day: 21))!
    @FocusState private var isEditingNotes: Bool
    @State private var isOntheClockTimeVisible = true
    private let navigate: (ClosedRange<Date>) -> Void
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(quickActionProvider: QuickActionProvider, navigate: @escaping (ClosedRange<Date>) -> Void) {
        self.quickActionProvider = quickActionProvider
        self.navigate = navigate
    }
    
    var body: some View {
        VStack {
            switch clockInState {
            case .clockedOut:
                Button {
                    clockInDate = getRoundedNow()
                    notes = ""
                    isClockingIn = true
                } label: {
                    Text("Clock In...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                }
                .buttonStyle(TimeClockButton())
                .padding()
                .accessibilityIdentifier("ClockInButton")
            case .clockedInWorking, .clockedInTakingABreak:
                Text(Formatting.timeIntervalFormatter.string(from: max(clockInDuration, TimeInterval())) ?? "")
                    .contentTransition(.numericText(value: clockInDuration))
                    .foregroundStyle((clockInState == .clockedInTakingABreak || clockInDuration < 0) ? .secondary : .primary)
                    .font(.system(size: 1000, design: .rounded))
                    .minimumScaleFactor(0.005)
                    .lineLimit(1)
                    .frame(maxHeight: 300)
                    .accessibilityIdentifier("ClockInDurationText")
                if clockInState == .clockedInTakingABreak {
                    Text("Started Break at \(Formatting.startEndFormatter.string(from: breakStart))")
                }
                Text(sinceClockIn < 0 ? "Clocking in at \(Formatting.startEndFormatter.string(from: clockInDate))..." : "Clocked in at \(Formatting.startEndFormatter.string(from: clockInDate))")
                    .foregroundStyle(clockInState == .clockedInTakingABreak ? .secondary : .primary)
                    .padding()
                HStack {
                    if clockInState == .clockedInWorking {
                        Button {
                            isStartingBreak = startTakingBreak()
                        } label: {
                            Image(systemName: "pause.fill")
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .accessibilityIdentifier("StartBreakButton")
                        .buttonStyle(TimeClockButton())
                        .padding()
                        Button {
                            isClockingOut = startClockingOut()
                        } label: {
                            Image(systemName: "stop.fill")
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .accessibilityIdentifier("ClockOutButton")
                        .buttonStyle(TimeClockButton())
                        .padding()
                    } else if clockInState == .clockedInTakingABreak {
                        Button {
                            isEndingBreak = startEndingBreak()
                        } label: {
                            Image(systemName: "play.fill")
                                .padding()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .accessibilityIdentifier("EndBreakButton")
                        .buttonStyle(TimeClockButton())
                        .padding()
                    }
                }
                TextField("Notes", text: $notes)
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
                TimeSheetOnTheClockView(payPeriod: $payPeriod, clockInDuration: $clockInDuration)
                    .padding()
                    .onTapGesture {
                        navigate(payPeriod)
                    }
            }
        }
        .onChange(of: quickActionProvider.quickAction) { _, _ in
            handleQuickAction()
        }
        .onAppear(perform: handleQuickAction)
        .sensoryFeedback(trigger: clockInState) { old, new in
            return switch new {
            case .clockedOut: .success
            case .clockedInWorking, .clockedInTakingABreak: old == .clockedOut ? .impact : nil
            }
        }
        .onAppear { updateClockInDuration(input: dateProvider.now) }
        .onReceive(timer, perform: updateClockInDuration)
        .sheet(isPresented: $isClockingIn) { [clockInDate, minuteInterval] in
            NavigationStack {
                IntervalDatePicker(selection: $clockInDate, minuteInterval: minuteInterval, displayedComponents: [.date, .hourAndMinute], style: .wheels)
                    .accessibilityIdentifier("ClockInDatePicker")
                    .navigationTitle("Clock In")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Start") {
                                clockIn(at: clockInDate)
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
        .sheet(isPresented: $isClockingOut) { [clockOutDate, minClockOutDate, minuteInterval] in
            NavigationStack {
                IntervalDatePicker(selection: $clockOutDate, minuteInterval: minuteInterval, in: minClockOutDate..., displayedComponents: [.date, .hourAndMinute], style: .wheels)
                    .accessibilityIdentifier("ClockOutDatePicker")
                    .navigationTitle("Clock Out")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Stop") {
                                clockOut(at: clockOutDate, notes: notes)
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
        .sheet(isPresented: $isStartingBreak) { [breakStart, minBreakStart, minuteInterval] in
            NavigationStack {
                IntervalDatePicker(selection: $breakStart, minuteInterval: minuteInterval, in: minBreakStart..., displayedComponents: [.date, .hourAndMinute], style: .wheels)
                    .accessibilityIdentifier("StartBreakDatePicker")
                    .navigationTitle("Take a Break")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Pause") {
                                startBreak(at: breakStart)
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
        .sheet(isPresented: $isEndingBreak) { [minBreakEndDate, breakEnd, minuteInterval] in
            NavigationStack {
                IntervalDatePicker(selection: $breakEnd, minuteInterval: minuteInterval, in: minBreakEndDate..., displayedComponents: [.date, .hourAndMinute], style: .wheels)
                    .accessibilityIdentifier("EndBreakDatePicker")
                    .navigationTitle("Go back to work")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Resume") {
                                endBreak(at: breakEnd)
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
    
    private func startClockingOut() -> Bool {
        guard clockInState == .clockedInWorking else {
            return false
        }
        
        guard let newDate = Calendar.current.date(byAdding: .minute, value: minuteInterval, to: clockInDate) else {
            return false
        }
        
        minClockOutDate = Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: newDate)
        clockOutDate = max(minClockOutDate, Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: dateProvider.now))
        return true
    }
    
    private func startTakingBreak() -> Bool {
        guard clockInState == .clockedInWorking else {
            return false
        }
        
        guard let newDate = Calendar.current.date(byAdding: .minute, value: minuteInterval, to: clockInDate) else {
            return false
        }
        
        minBreakStart = Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: newDate)
        breakStart = max(minBreakStart, Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: dateProvider.now))
        return true
    }
    
    private func startEndingBreak() -> Bool {
        guard clockInState == .clockedInTakingABreak else {
            return false
        }
        
        guard let newDate = Calendar.current.date(byAdding: .minute, value: minuteInterval, to: breakStart) else {
            return false
        }
        
        minBreakEndDate = Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: newDate)
        breakEnd = max(minBreakEndDate, Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: dateProvider.now))
        return true
    }
    
    private func updateClockInDuration(input: Date) {
        withAnimation {
            payPeriod = dateProvider.now.getPayPeriod(schedule: payPeriodSchedule, periodEnd: endOfLastPayPeriod)
        }
        switch clockInState {
        case .clockedOut:
            sinceClockIn = .zero
            clockInDuration = .zero
            break
        case .clockedInWorking:
            withAnimation {
                let onBreak = breaks.reduce(TimeInterval()) { $0 + $1.interval }
                let clockInDate = clockInDate
                let sinceClockIn = clockInDate.distance(to: dateProvider.now)
                self.sinceClockIn = sinceClockIn
                clockInDuration = sinceClockIn - onBreak
            }
            break
        case .clockedInTakingABreak:
            let onBreak = breaks.reduce(TimeInterval()) { $0 + $1.interval }
            sinceClockIn = clockInDate.distance(to: dateProvider.now)
            let sinceBreakStart = max(TimeInterval(), breakStart.distance(to: dateProvider.now))
            clockInDuration = sinceClockIn - onBreak - sinceBreakStart
            break
        }
    }
    
    func getRoundedNow() -> Date {
        return Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: dateProvider.now)
    }
    
    private func handle(_ quickAction: QuickAction) {
        switch quickAction {
        case .clockIn:
            clockIn(at: getRoundedNow())
            break
        case .clockOut:
            if startClockingOut() {
                clockOut(at: clockOutDate, notes: notes)
            }
            break
        case .startBreak:
            if startTakingBreak() {
                startBreak(at: breakStart)
            }
            break
        case .endBreak:
            if startEndingBreak() {
                endBreak(at: breakEnd)
            }
        }
    }
    
    func handleQuickAction() {
        guard let quickAction = quickActionProvider.quickAction else {
            return
        }
        
        handle(quickAction)
        quickActionProvider.quickAction = nil
    }
    
    func clockIn(at clockInDate: Date) {
        guard clockInState == .clockedOut else {
            return
        }
        self.clockInDate = clockInDate
        breaks = [BreakEntry]()
        notes = ""
        clockInState = .clockedInWorking
        updateClockInDuration(input: dateProvider.now)
    }
    
    func startBreak(at breakStart: Date) {
        guard clockInState == .clockedInWorking else {
            return
        }
        
        self.breakStart = breakStart
        clockInState = .clockedInTakingABreak
        updateClockInDuration(input: dateProvider.now)
    }
    
    func endBreak(at breakEnd: Date) {
        guard clockInState == .clockedInTakingABreak else {
            return
        }
        breaks = breaks + [BreakEntry(start: breakStart, end: breakEnd)]
        clockInState = .clockedInWorking
        updateClockInDuration(input: dateProvider.now)
    }
    
    func clockOut(at end: Date, notes: String) {
        guard clockInState == .clockedInWorking && clockInDate != end else {
            return
        }
        
        let timeEntry = TimeEntry(from: clockInDate, to: end, notes: notes)
        timeEntry.breaks.append(contentsOf: breaks)
        context.insert(timeEntry)
        clockInState = .clockedOut
        updateClockInDuration(input: dateProvider.now)
    }
}
