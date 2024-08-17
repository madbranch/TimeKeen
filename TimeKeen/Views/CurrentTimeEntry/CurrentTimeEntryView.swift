import SwiftUI

struct CurrentTimeEntryView: View {
  var quickActionProvider: QuickActionProvider
  
  @AppStorage(SharedData.Keys.minuteInterval.rawValue, store: SharedData.userDefaults) var minuteInterval = 15 {
    didSet {
      UIDatePicker.appearance().minuteInterval = minuteInterval
    }
  }
  
  @Environment(\.modelContext) private var context
  @AppStorage(SharedData.Keys.clockInState.rawValue, store: SharedData.userDefaults) var clockInState = ClockInState.clockedOut
  @State private var clockInDuration: TimeInterval = .zero
  @State private var sinceClockIn: TimeInterval = .zero
  @State private var isClockingIn = false
  @State private var isClockingOut = false
  @AppStorage(SharedData.Keys.clockInDate.rawValue, store: SharedData.userDefaults) var clockInDate = Date()
  @State private var clockOutDate = Date()
  @State private var minClockOutDate = Date()
  @State private var notes = ""
  @State private var isStartingBreak = false
  @State private var isEndingBreak = false
  @State private var minBreakStart = Date()
  @AppStorage(SharedData.Keys.breakStart.rawValue, store: SharedData.userDefaults) var breakStart = Date()
  @State private var breakEnd = Date()
  @State private var minBreakEndDate = Date()
  @AppStorage(SharedData.Keys.breaks.rawValue, store: SharedData.userDefaults) var breaks = [BreakItem]()
  
  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  init(quickActionProvider: QuickActionProvider) {
    self.quickActionProvider = quickActionProvider
  }
  
  var body: some View {
    VStack {
      minuteIntervalPicker
        .padding()
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
            .font(.largeTitle)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .buttonBorderShape(.circle)
        .padding()
      case .clockedInWorking, .clockedInTakingABreak:
        Spacer()
        Text(Formatting.timeIntervalFormatter.string(from: max(clockInDuration, TimeInterval())) ?? "")
          .onAppear { updateClockInDuration(input: Date.now) }
          .onReceive(timer, perform: updateClockInDuration)
          .font(.system(size: 1000))
          .scaledToFit()
          .minimumScaleFactor(0.01)
          .lineLimit(1)
          .foregroundStyle(clockInDuration < 0 ? .secondary : .primary)
        if clockInState == .clockedInTakingABreak {
          Text("Started Break at \(Formatting.startEndFormatter.string(from: breakStart))")
            .foregroundStyle(.secondary)
        }
        Spacer()
        TextField("Notes", text: $notes)
          .padding()
          .textFieldStyle(.roundedBorder)
        if clockInState == .clockedInWorking {
          Button {
            isStartingBreak = startTakingBreak()
          } label: {
            Text("Take a Break...")
              .padding()
          }
        }
        Text(sinceClockIn < 0 ? "Clocking in at \(Formatting.startEndFormatter.string(from: clockInDate))..." : "Clocked in at \(Formatting.startEndFormatter.string(from: clockInDate))")
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .padding()
        if clockInState == .clockedInWorking {
          Button("Clock Out...", action: {
            isClockingOut = startClockingOut()
          })
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .padding()
        } else if clockInState == .clockedInTakingABreak {
          Button("End Break...", action: {
            isEndingBreak = startEndingBreak()
          })
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .padding()
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
    .sheet(isPresented: $isClockingIn) { [clockInDate, minuteInterval] in
      VStack {
        Text("Clock In")
          .font(.headline)
          .frame(maxWidth: .infinity, alignment: .center)
          .overlay(alignment: .trailing) {
            Button("Cancel", role: .cancel) {
              isClockingIn = false
            }
          }
        IntervalDatePicker(selection: $clockInDate, minuteInterval: minuteInterval, displayedComponents: [.date, .hourAndMinute], style: .wheels)
        Button(action: {
          clockIn(at: clockInDate)
          isClockingIn = false
        }) {
          Text("Clock In At \(Formatting.startEndFormatter.string(from: clockInDate))")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .frame(maxHeight: .infinity, alignment: .bottom)
      }
      .padding()
      .presentationDetents([.medium])
    }
    .sheet(isPresented: $isClockingOut) { [clockOutDate, minClockOutDate, minuteInterval] in
      VStack {
        Text("Clock Out")
          .font(.headline)
          .frame(maxWidth: .infinity, alignment: .center)
          .overlay(alignment: .trailing) {
            Button("Cancel", role: .cancel) {
              isClockingOut = false
            }
          }
        IntervalDatePicker(selection: $clockOutDate, minuteInterval: minuteInterval, in: minClockOutDate..., displayedComponents: [.date, .hourAndMinute], style: .wheels)
        Button(action: {
          clockOut(at: clockOutDate, notes: notes)
          isClockingOut = false
        }) {
          Text("Clock Out At \(Formatting.startEndFormatter.string(from: clockOutDate))")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .frame(maxHeight: .infinity, alignment: .bottom)
      }
      .padding()
      .presentationDetents([.medium])
    }
    .sheet(isPresented: $isStartingBreak) { [breakStart, minBreakStart, minuteInterval] in
      VStack {
        Text("Start Break")
          .font(.headline)
          .frame(maxWidth: .infinity, alignment: .center)
          .overlay(alignment: .trailing) {
            Button("Cancel", role: .cancel) {
              isStartingBreak = false
            }
          }
        IntervalDatePicker(selection: $breakStart, minuteInterval: minuteInterval, in: minBreakStart..., displayedComponents: [.date, .hourAndMinute], style: .wheels)
        Button(action: {
          startBreak(at: breakStart)
          isStartingBreak = false
        }) {
          Text("Start Break at \(Formatting.startEndFormatter.string(from: breakStart))")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .frame(maxHeight: .infinity, alignment: .bottom)
      }
      .padding()
      .presentationDetents([.medium])
    }
    .sheet(isPresented: $isEndingBreak) { [minBreakEndDate, breakEnd, minuteInterval] in
      VStack {
        Text("End Break")
          .font(.headline)
          .frame(maxWidth: .infinity, alignment: .center)
          .overlay(alignment: .trailing) {
            Button("Cancel", role: .cancel) {
              isEndingBreak = false
            }
          }
        IntervalDatePicker(selection: $breakEnd, minuteInterval: minuteInterval, in: minBreakEndDate..., displayedComponents: [.date, .hourAndMinute], style: .wheels)
        Button(action: {
          endBreak(at: breakEnd)
          isEndingBreak = false
        }) {
          Text("End Break at \(Formatting.startEndFormatter.string(from: breakEnd))")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .frame(maxHeight: .infinity, alignment: .bottom)
      }
      .padding()
      .presentationDetents([.medium])
    }
  }
  
  var minuteIntervalPicker: some View {
    Picker("Minute Interval", selection: $minuteInterval) {
      Text("1 minute").tag(1)
      Text("5 minutes").tag(5)
      Text("10 minutes").tag(10)
      Text("15 minutes").tag(15)
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
    clockOutDate = max(minClockOutDate, Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: Date()))
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
    breakStart = max(minBreakStart, Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: Date()))
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
    breakEnd = max(minBreakEndDate, Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: Date()))
    return true
  }
  
  private func updateClockInDuration(input: Date) {
    switch clockInState {
    case .clockedOut:
      sinceClockIn = .zero
      clockInDuration = .zero
      break
    case .clockedInWorking:
      let onBreak = breaks.reduce(TimeInterval()) { $0 + $1.interval }
      sinceClockIn = clockInDate.distance(to: input)
      clockInDuration = sinceClockIn - onBreak
      break
    case .clockedInTakingABreak:
      let onBreak = breaks.reduce(TimeInterval()) { $0 + $1.interval }
      sinceClockIn = clockInDate.distance(to: input)
      let sinceBreakStart = max(TimeInterval(), breakStart.distance(to: input))
      clockInDuration = sinceClockIn - onBreak - sinceBreakStart
      break
    }
  }
  
  func getRoundedNow() -> Date {
    return Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: Date())
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
    breaks = [BreakItem]()
    notes = ""
    clockInState = .clockedInWorking
  }
  
  func startBreak(at breakStart: Date) {
    guard clockInState == .clockedInWorking else {
      return
    }
    
    self.breakStart = breakStart
    clockInState = .clockedInTakingABreak
  }
  
  func endBreak(at breakEnd: Date) {
    guard clockInState == .clockedInTakingABreak else {
      return
    }
    breaks = breaks + [BreakItem(start: breakStart, end: breakEnd)]
    clockInState = .clockedInWorking
  }
  
  func clockOut(at end: Date, notes: String) {
    guard clockInState == .clockedInWorking && clockInDate != end else {
      return
    }
    
    let timeEntry = TimeEntry(from: clockInDate, to: end, notes: notes)
    timeEntry.breaks.append(contentsOf: breaks.map { BreakEntry(start: $0.start, end: $0.end) })
    context.insert(timeEntry)
    clockInState = .clockedOut
  }
}
