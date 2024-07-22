import SwiftUI

struct CurrentTimeEntryView: View {
  var viewModel: CurrentTimeEntryViewModel
  
  @AppStorage("MinuteInterval") var minuteInterval = 15
  @State private var clockInDuration: Duration = .zero
  @State private var isClockingIn = false
  @State private var isClockingOut = false
  @State private var clockInDate = Formatting.getRoundedDate()
  @State private var clockOutDate = Formatting.getRoundedDate()
  @State private var minClockOutDate = Date()
  @State private var notes = ""
  @State private var isStartingBreak = false
  @State private var isEndingBreak = false
  @State private var breakStart = Formatting.getRoundedDate()
  @State private var breakEnd = Formatting.getRoundedDate()
  @State private var minBreakEndDate = Date()
  
  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  private static let durationStyle = Duration.TimeFormatStyle(pattern: .hourMinute)
  
  init(viewModel: CurrentTimeEntryViewModel) {
    self.viewModel = viewModel
  }
  
  private func updateClockInDuration(input: Date) {
    let components = Calendar.current.dateComponents([.hour, .minute], from: viewModel.clockInDate, to: input)
    
    if let hour = components.hour, let minute = components.minute  {
      clockInDuration = .seconds(hour * 60 * 60 + minute * 60)
    } else {
      clockInDuration = .zero
    }
  }
  
  var body: some View {
    VStack {
      switch viewModel.clockInState {
      case .clockedOut:
        Button {
          clockInDate = Formatting.getRoundedDate()
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
        Text(clockInDuration.formatted(CurrentTimeEntryView.durationStyle))
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
            breakStart = Formatting.getRoundedDate()
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
            guard let newDate = Calendar.current.date(byAdding: .minute, value: UserDefaults.standard.minuteInterval, to: clockInDate) else {
              return
            }
            
            minClockOutDate = newDate
            clockOutDate = newDate
            isClockingOut = true
          })
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .padding()
        case .takingABreak:
          Button("End Break...", action: {
            guard let newDate = Calendar.current.date(byAdding: .minute, value: UserDefaults.standard.minuteInterval, to: breakStart) else {
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
    .sheet(isPresented: $isClockingIn) { [clockInDate] in
      VStack {
        LabeledContent("At") {
          IntervalDatePicker(selection: $clockInDate, minuteInterval: minuteInterval, displayedComponents: [.date, .hourAndMinute])
        }
        .padding()
        Button("Clock In at \(Formatting.startEndFormatter.string(from: clockInDate))", action: {
          viewModel.clockIn(at: clockInDate)
          isClockingIn = false
        })
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding()
      }
      .presentationDetents([
        .fraction(0.2)
      ])
    }
    .sheet(isPresented: $isClockingOut) { [clockOutDate] in
      VStack {
        LabeledContent("At") {
          IntervalDatePicker(selection: $clockOutDate, minuteInterval: minuteInterval, in: minClockOutDate..., displayedComponents: [.date, .hourAndMinute])
        }
        .padding()
        Button("Clock Out at \(Formatting.startEndFormatter.string(from: clockOutDate))", action: {
          _ = viewModel.clockOut(at: clockOutDate, notes: notes)
          isClockingOut = false
        })
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding()
      }
      .presentationDetents([
        .fraction(0.2)
      ])
    }
    .sheet(isPresented: $isStartingBreak) { [breakStart] in
      VStack {
        LabeledContent("At") {
          IntervalDatePicker(selection: $breakStart, minuteInterval: minuteInterval, in: clockInDate..., displayedComponents: [.date, .hourAndMinute])
        }
        .padding()
        Button("Start Break at \(Formatting.startEndFormatter.string(from: breakStart))", action: {
          viewModel.startBreak(at: breakStart)
          isStartingBreak = false
        })
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding()
      }
      .presentationDetents([
        .fraction(0.2)
      ])
    }
    .sheet(isPresented: $isEndingBreak) { [breakEnd] in
      VStack {
        LabeledContent("At") {
          IntervalDatePicker(selection: $breakEnd, minuteInterval: minuteInterval, in: breakStart..., displayedComponents: [.date, .hourAndMinute])
        }
        .padding()
        Button("End Break at \(Formatting.startEndFormatter.string(from: breakEnd))", action: {
          viewModel.endBreak(at: breakEnd)
          isEndingBreak = false
        })
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding()
      }
      .presentationDetents([
        .fraction(0.2)
      ])
    }
  }
}
