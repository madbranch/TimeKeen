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
  @State private var isClockingIn = false
  @State private var isClockingOut = false
  @AppStorage(SharedData.Keys.clockInDate.rawValue, store: SharedData.userDefaults) var clockInDate = Date()
  @State private var clockOutDate = Date()
  @State private var minClockOutDate = Date()
  @State private var notes = ""
  @State private var isStartingBreak = false
  @State private var isEndingBreak = false
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
      Picker("Minute Interval", selection: $minuteInterval) {
        Text("1 minute").tag(1)
        Text("5 minutes").tag(5)
        Text("10 minutes").tag(10)
        Text("15 minutes").tag(15)
      }
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
            breakStart = getRoundedNow()
            isStartingBreak = true
          } label: {
            Text("Take a Break...")
              .padding()
          }
        }
        Text(clockInDuration < 0 ? "Clocking in at \(Formatting.startEndFormatter.string(from: clockInDate))..." : "Clocked in at \(Formatting.startEndFormatter.string(from: clockInDate))")
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .padding()
        if clockInState == .clockedInWorking {
          Button("Clock Out...", action: {
            guard let newDate = Calendar.current.date(byAdding: .minute, value: minuteInterval, to: clockInDate) else {
              return
            }
            
            minClockOutDate = Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: newDate)
            clockOutDate = max(minClockOutDate, Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: Date()))
            isClockingOut = true
          })
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .padding()
        } else if clockInState == .clockedInTakingABreak {
          Button("End Break...", action: {
            guard let newDate = Calendar.current.date(byAdding: .minute, value: minuteInterval, to: breakStart) else {
              return
            }
            
            minBreakEndDate = Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: newDate)
            breakEnd = max(minBreakEndDate, Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: Date()))
            isEndingBreak = true
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
          _ = clockOut(at: clockOutDate, notes: notes)
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
    .sheet(isPresented: $isStartingBreak) { [breakStart, clockInDate, minuteInterval] in
      VStack {
        Text("Start Break")
          .font(.headline)
          .frame(maxWidth: .infinity, alignment: .center)
          .overlay(alignment: .trailing) {
            Button("Cancel", role: .cancel) {
              isStartingBreak = false
            }
          }
        IntervalDatePicker(selection: $breakStart, minuteInterval: minuteInterval, in: clockInDate..., displayedComponents: [.date, .hourAndMinute], style: .wheels)
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
    .sheet(isPresented: $isEndingBreak) { [breakStart, breakEnd, minuteInterval] in
      VStack {
        Text("End Break")
          .font(.headline)
          .frame(maxWidth: .infinity, alignment: .center)
          .overlay(alignment: .trailing) {
            Button("Cancel", role: .cancel) {
              isEndingBreak = false
            }
          }
        IntervalDatePicker(selection: $breakEnd, minuteInterval: minuteInterval, in: breakStart..., displayedComponents: [.date, .hourAndMinute], style: .wheels)
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
  
  private func updateClockInDuration(input: Date) {
    clockInDuration = clockInDate.distance(to: input)
  }
  
  func getRoundedNow() -> Date {
    return Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: Date())
  }
  
  private func handle(_ quickAction: QuickAction) {
    switch quickAction {
    case .clockIn:
      if clockInState == .clockedOut {
        notes = ""
        clockIn(at: getRoundedNow())
      }
      break
    case .clockOut:
      if clockInState == .clockedInWorking {
        _ = clockOut(at: getRoundedNow(), notes: notes)
      }
      break
    case .startBreak:
      if clockInState == .clockedInWorking {
        startBreak(at: getRoundedNow())
      }
      break
    case .endBreak:
      if clockInState == .clockedInTakingABreak {
        endBreak(at: getRoundedNow())
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
    switch clockInState {
    case .clockedInWorking:
      return
    case .clockedInTakingABreak:
      return
    case .clockedOut:
      self.clockInDate = clockInDate
      breaks = [BreakItem]()
      clockInState = .clockedInWorking
    }
  }
    
  func startBreak(at breakStart: Date) {
    switch clockInState {
    case .clockedOut:
      return
    case .clockedInWorking:
      self.breakStart = breakStart
      clockInState = .clockedInTakingABreak
      break
    case .clockedInTakingABreak:
      return
    }
  }
  
  func endBreak(at breakEnd: Date) {
    switch clockInState {
    case .clockedOut:
      return
    case .clockedInTakingABreak:
      breaks = breaks + [BreakItem(start: breakStart, end: breakEnd)]
      clockInState = .clockedInWorking
      break
    case .clockedInWorking:
      return
    }
  }
  
  func clockOut(at end: Date, notes: String) -> Result<TimeEntry, ClockOutError> {
    switch clockInState {
    case .clockedOut:
      return .failure(.notClockedIn)
    case .clockedInTakingABreak:
      return .failure(.notWorking)
    case .clockedInWorking:
      guard clockInDate != end else {
        return .failure(.startAndEndEqual)
      }
      
      let timeEntry = TimeEntry(from: clockInDate, to: end, notes: notes)
      timeEntry.breaks.append(contentsOf: breaks.map { BreakEntry(start: $0.start, end: $0.end) })
      context.insert(timeEntry)
      clockInState = .clockedOut
      return .success(timeEntry)
    }
  }
}
