import SwiftUI

struct CurrentTimeEntryView: View {
  @ObservedObject var viewModel: CurrentTimeEntryViewModel
  
  @State private var clockInDuration: Duration = .zero
  
  @State private var isClockingIn = false
  @State private var isClockingOut = false
  @State private var clockInDate = CurrentTimeEntryView.getRoundedDate()
  @State private var clockOutDate = CurrentTimeEntryView.getRoundedDate()
  @State private var minClockOutDate = Date()
  @State private var notes = ""
  @State private var isStartingBreak = false
  @State private var isEndingBreak = false
  @State private var breakStart = CurrentTimeEntryView.getRoundedDate()
  @State private var breakEnd = CurrentTimeEntryView.getRoundedDate()

  private let dateFormat: DateFormatter
  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  private static let durationStyle = Duration.TimeFormatStyle(pattern: .hourMinute)
  
  init(viewModel: CurrentTimeEntryViewModel) {
    self.viewModel = viewModel
    dateFormat = DateFormatter()
    dateFormat.dateFormat = "HH:mm"
  }
  
  private func updateClockInDuration(input: Date) {
    let components = Calendar.current.dateComponents([.hour, .minute], from: viewModel.clockInDate, to: input)
    
    if let hour = components.hour, let minute = components.minute  {
      clockInDuration = .seconds(hour * 60 * 60 + minute * 60)
    } else {
      clockInDuration = .zero
    }
  }
  
  private static func getRoundedDate() -> Date {
    let date = Date()
    let components = Calendar.current.dateComponents([.minute], from: date)
    
    guard let minute = components.minute else {
      return date
    }
    
    let roundedMinutes = Int((Double(minute) / 15.0).rounded(.toNearestOrAwayFromZero) * 15.0)
    
    return Calendar.current.date(byAdding: .minute, value: roundedMinutes - minute, to: date) ?? Date()
  }
  
  var body: some View {
    VStack {
      switch viewModel.clockInState {
      case .clockedOut:
        Button {
          clockInDate = CurrentTimeEntryView.getRoundedDate()
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
        Spacer()
        TextField("Notes", text: $notes, axis: .vertical)
          .padding()
          .textFieldStyle(.roundedBorder)
        switch breakState {
        case .working:
          Button {
            isStartingBreak = true
          } label: {
            Text("Take a Break...")
              .padding()
          }
        case .takingABreak:
          Button {
            isEndingBreak = true
          } label: {
            Text("Go Back to Work...")
              .padding()
          }
        }
        Text("Clocked in at \(self.dateFormat.string(from: viewModel.clockInDate))")
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .padding()
        Button("Clock Out...", action: {
          guard let newDate = Calendar.current.date(byAdding: .minute, value: 15, to: clockInDate) else {
            return
          }
          
          minClockOutDate = newDate
          clockOutDate = newDate
          isClockingOut = true
        })
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding()
      }
    }
    .sheet(isPresented: $isClockingIn) {
      VStack {
        DatePicker("At", selection: $clockInDate, displayedComponents: [.date, .hourAndMinute])
          .datePickerStyle(.compact)
          .padding()
        Button("Clock In at \(self.dateFormat.string(from: clockInDate))", action: {
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
    .sheet(isPresented: $isClockingOut) {
      VStack {
        DatePicker("At", selection: $clockOutDate, in: minClockOutDate..., displayedComponents: [.date, .hourAndMinute])
          .datePickerStyle(.compact)
          .padding()
        Button("Clock Out at \(self.dateFormat.string(from: clockOutDate))", action: {
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
    .sheet(isPresented: $isStartingBreak) {
      VStack {
        DatePicker("At", selection: $breakStart, displayedComponents: [.date, .hourAndMinute])
          .datePickerStyle(.compact)
          .padding()
        Button("Start Break at \(self.dateFormat.string(from: breakStart))", action: {
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
    .sheet(isPresented: $isEndingBreak) {
      VStack {
        DatePicker("At", selection: $breakEnd, displayedComponents: [.date, .hourAndMinute])
          .datePickerStyle(.compact)
          .padding()
        Button("Ending Break at \(self.dateFormat.string(from: breakEnd))", action: {
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
