import SwiftUI

struct CurrentTimeEntryView: View {
  @Bindable var viewModel: CurrentTimeEntryViewModel
  
  @AppStorage("MinuteInterval") var minuteInterval = 15
  @State private var clockInDuration: TimeInterval = .zero
  @State private var isClockingIn = false
  @State private var isClockingOut = false
  @State private var clockOutDate = Date()
  @State private var minClockOutDate = Date()
  @State private var notes = ""
  @State private var isStartingBreak = false
  @State private var isEndingBreak = false
  @State private var breakEnd = Date()
  @State private var minBreakEndDate = Date()
  
  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  init(viewModel: CurrentTimeEntryViewModel) {
    self.viewModel = viewModel
  }
  
  private func updateClockInDuration(input: Date) {
    clockInDuration = viewModel.clockInDate.distance(to: input)
  }
  
  var body: some View {
    VStack {
      switch viewModel.clockInState {
      case .clockedOut:
        Button {
          viewModel.clockInDate = Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: Date())
          print(Formatting.startEndWithDateFormatter.string(from: viewModel.clockInDate))
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
        .clipShape(Circle())
        .padding()
      case .clockedIn(let breakState):
        Spacer()
        Text((clockInDuration < 0 ? "-" : "") + (Formatting.timeIntervalFormatter.string(from: clockInDuration) ?? ""))
          .onAppear { updateClockInDuration(input: Date.now) }
          .onReceive(timer, perform: updateClockInDuration)
          .font(.system(size: 1000))
          .scaledToFit()
          .minimumScaleFactor(0.01)
          .lineLimit(1)
        if breakState == .takingABreak {
          Text("Started Break at \(Formatting.startEndFormatter.string(from: viewModel.breakStart))")
            .foregroundStyle(.secondary)
        }
        Spacer()
        TextField("Notes", text: $notes, axis: .vertical)
          .padding()
          .textFieldStyle(.roundedBorder)
        if breakState == .working {
          Button {
            viewModel.breakStart = Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: Date())
            isStartingBreak = true
          } label: {
            Text("Take a Break...")
              .padding()
          }
        }
        Text("Clocked in at \(Formatting.startEndFormatter.string(from: viewModel.clockInDate))")
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .padding()
        switch breakState {
        case .working:
          Button("Clock Out...", action: {
            guard let newDate = Calendar.current.date(byAdding: .minute, value: UserDefaults.standard.minuteInterval, to: viewModel.clockInDate) else {
              return
            }
            
            minClockOutDate = Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: newDate)
            clockOutDate = Calendar.current.getRoundedDate(minuteInterval: minuteInterval, from: max(newDate, Date()))
            isClockingOut = true
          })
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .padding()
        case .takingABreak:
          Button("End Break...", action: {
            guard let newDate = Calendar.current.date(byAdding: .minute, value: UserDefaults.standard.minuteInterval, to: viewModel.breakStart) else {
              return
            }
            
            minBreakEndDate = newDate
            breakEnd = newDate
            isEndingBreak = true
          })
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .padding()
        }
      }
    }
    .sensoryFeedback(trigger: viewModel.clockInState) { old, new in
      return switch new {
      case .clockedOut: .success
      case .clockedIn(_): old == .clockedOut ? .impact : nil
      }
    }
    .sheet(isPresented: $isClockingIn) { [viewModel, minuteInterval] in
      VStack {
        LabeledContent("At") {
          IntervalDatePicker(selection: $viewModel.clockInDate, minuteInterval: minuteInterval, displayedComponents: [.date, .hourAndMinute])
        }
        Button(action: {
          viewModel.clockIn(at: viewModel.clockInDate)
          isClockingIn = false
        }) {
          Text("Clock In at \(Formatting.startEndFormatter.string(from: viewModel.clockInDate))")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
      }
      .padding()
      .presentationDetents([
        .fraction(0.2)
      ])
    }
    .sheet(isPresented: $isClockingOut) { [clockOutDate, minClockOutDate, minuteInterval] in
      VStack {
        LabeledContent("At") {
          IntervalDatePicker(selection: $clockOutDate, minuteInterval: minuteInterval, in: minClockOutDate..., displayedComponents: [.date, .hourAndMinute])
        }
        Button(action: {
          _ = viewModel.clockOut(at: clockOutDate, notes: notes)
          isClockingOut = false
        }) {
          Text("Clock Out at \(Formatting.startEndFormatter.string(from: clockOutDate))")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
      }
      .padding()
      .presentationDetents([
        .fraction(0.2)
      ])
    }
    .sheet(isPresented: $isStartingBreak) { [viewModel, minuteInterval] in
      VStack {
        LabeledContent("At") {
          IntervalDatePicker(selection: $viewModel.breakStart, minuteInterval: minuteInterval, in: viewModel.clockInDate..., displayedComponents: [.date, .hourAndMinute])
        }
        Button(action: {
          viewModel.startBreak(at: viewModel.breakStart)
          isStartingBreak = false
        }) {
          Text("Start Break at \(Formatting.startEndFormatter.string(from: viewModel.breakStart))")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
      }
      .padding()
      .presentationDetents([
        .fraction(0.2)
      ])
    }
    .sheet(isPresented: $isEndingBreak) { [viewModel, breakEnd] in
      VStack {
        LabeledContent("At") {
          IntervalDatePicker(selection: $breakEnd, minuteInterval: minuteInterval, in: viewModel.breakStart..., displayedComponents: [.date, .hourAndMinute])
        }
        Button(action: {
          viewModel.endBreak(at: breakEnd)
          isEndingBreak = false
        }) {
          Text("End Break at \(Formatting.startEndFormatter.string(from: breakEnd))")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
      }
      .padding()
      .presentationDetents([
        .fraction(0.2)
      ])
    }
  }
}
