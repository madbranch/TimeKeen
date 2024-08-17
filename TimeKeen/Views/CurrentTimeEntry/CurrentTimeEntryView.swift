import SwiftUI

struct CurrentTimeEntryView: View {
  @Bindable var viewModel: CurrentTimeEntryViewModel
  
  @AppStorage(SharedData.Keys.minuteInterval.rawValue, store: SharedData.userDefaults) var minuteInterval = 15 {
    didSet {
      UIDatePicker.appearance().minuteInterval = minuteInterval
    }
  }
  //@AppStorage(SharedData.Keys.clockInState.rawValue, store: SharedData.userDefaults) var clockInState = ClockInState.clockedOut
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
  
  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  init(viewModel: CurrentTimeEntryViewModel) {
    self.viewModel = viewModel
  }
  
  private func updateClockInDuration(input: Date) {
    clockInDuration = viewModel.clockInDate.distance(to: input)
  }
  
  func getRoundedNow() -> Date {
    return Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: Date())
  }
  
  private func handle(_ quickAction: QuickAction) {
    switch quickAction {
    case .clockIn:
      if viewModel.clockInState == .clockedOut {
        notes = ""
        viewModel.clockIn(at: getRoundedNow())
      }
      break
    case .clockOut:
      if viewModel.clockInState == .clockedInWorking {
        _ = viewModel.clockOut(at: getRoundedNow(), notes: notes)
      }
      break
    case .startBreak:
      if viewModel.clockInState == .clockedInWorking {
        viewModel.startBreak(at: getRoundedNow())
      }
      break
    case .endBreak:
      if viewModel.clockInState == .clockedInTakingABreak {
        viewModel.endBreak(at: getRoundedNow())
      }
    }
  }
  
  func handleQuickAction() {
    guard let quickAction = viewModel.quickActionProvider.quickAction else {
      return
    }
    
    handle(quickAction)
    
    viewModel.quickActionProvider.quickAction = nil
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
      switch viewModel.clockInState {
      case .clockedOut:
        Button {
          viewModel.clockInDate = getRoundedNow()
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
        if viewModel.clockInState == .clockedInTakingABreak {
          Text("Started Break at \(Formatting.startEndFormatter.string(from: viewModel.breakStart))")
            .foregroundStyle(.secondary)
        }
        Spacer()
        TextField("Notes", text: $notes)
          .padding()
          .textFieldStyle(.roundedBorder)
        if viewModel.clockInState == .clockedInWorking {
          Button {
            viewModel.breakStart = getRoundedNow()
            isStartingBreak = true
          } label: {
            Text("Take a Break...")
              .padding()
          }
        }
        Text(clockInDuration < 0 ? "Clocking in at \(Formatting.startEndFormatter.string(from: viewModel.clockInDate))..." : "Clocked in at \(Formatting.startEndFormatter.string(from: viewModel.clockInDate))")
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .padding()
        if viewModel.clockInState == .clockedInWorking {
          Button("Clock Out...", action: {
            guard let newDate = Calendar.current.date(byAdding: .minute, value: minuteInterval, to: viewModel.clockInDate) else {
              return
            }
            
            minClockOutDate = Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: newDate)
            clockOutDate = Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: max(newDate, Date()))
            isClockingOut = true
          })
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .padding()
        } else if viewModel.clockInState == .clockedInTakingABreak {
          Button("End Break...", action: {
            guard let newDate = Calendar.current.date(byAdding: .minute, value: minuteInterval, to: viewModel.breakStart) else {
              return
            }
            
            minBreakEndDate = Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: newDate)
            breakEnd = Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: max(newDate, Date()))
            isEndingBreak = true
          })
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .padding()
        }
      }
    }
    .onChange(of: viewModel.quickActionProvider.quickAction) { _, _ in
      handleQuickAction()
    }
    .onAppear(perform: handleQuickAction)
    .sensoryFeedback(trigger: viewModel.clockInState) { old, new in
      return switch new {
      case .clockedOut: .success
      case .clockedInWorking, .clockedInTakingABreak: old == .clockedOut ? .impact : nil
      }
    }
    .sheet(isPresented: $isClockingIn) { [viewModel, clockInDate = viewModel.clockInDate, minuteInterval] in
      VStack {
        Text("Clock In")
          .font(.headline)
          .frame(maxWidth: .infinity, alignment: .center)
          .overlay(alignment: .trailing) {
            Button("Cancel", role: .cancel) {
              isClockingIn = false
            }
          }
        IntervalDatePicker(selection: $viewModel.clockInDate, minuteInterval: minuteInterval, displayedComponents: [.date, .hourAndMinute], style: .wheels)
        Button(action: {
          viewModel.clockIn(at: viewModel.clockInDate)
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
          _ = viewModel.clockOut(at: clockOutDate, notes: notes)
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
    .sheet(isPresented: $isStartingBreak) { [viewModel, minuteInterval] in
      VStack {
        Text("Start Break")
          .font(.headline)
          .frame(maxWidth: .infinity, alignment: .center)
          .overlay(alignment: .trailing) {
            Button("Cancel", role: .cancel) {
              isStartingBreak = false
            }
          }
        IntervalDatePicker(selection: $viewModel.breakStart, minuteInterval: minuteInterval, in: viewModel.clockInDate..., displayedComponents: [.date, .hourAndMinute], style: .wheels)
        Button(action: {
          viewModel.startBreak(at: viewModel.breakStart)
          isStartingBreak = false
        }) {
          Text("Start Break at \(Formatting.startEndFormatter.string(from: viewModel.breakStart))")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .frame(maxHeight: .infinity, alignment: .bottom)
      }
      .padding()
      .presentationDetents([.medium])
    }
    .sheet(isPresented: $isEndingBreak) { [viewModel, breakEnd] in
      VStack {
        Text("End Break")
          .font(.headline)
          .frame(maxWidth: .infinity, alignment: .center)
          .overlay(alignment: .trailing) {
            Button("Cancel", role: .cancel) {
              isStartingBreak = false
            }
          }
        IntervalDatePicker(selection: $breakEnd, minuteInterval: minuteInterval, in: viewModel.breakStart..., displayedComponents: [.date, .hourAndMinute], style: .wheels)
        Button(action: {
          viewModel.endBreak(at: breakEnd)
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
}
