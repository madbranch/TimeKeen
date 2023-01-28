import SwiftUI

struct ClockInButtonStyle: ButtonStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .foregroundColor(.primary)
      .background(Color(UIColor.tintColor))
      .clipShape(Circle())
      .shadow(radius: 10)
  }
}

enum ClockInState {
  case ClockedOut
  case ClockingIn
  case ClockedIn
  case ClockingOut
}

struct CurrentTimeEntryView: View {
  @Environment(\.managedObjectContext) private var viewContext
  
  @ObservedObject var viewModel: CurrentTimeEntryViewModel
  
  @State private var clockInState: ClockInState = .ClockedOut
  @State private var clockInDate = Date()
  @State private var clockOutDate = Date()
  @State private var minClockOutDate = Date()
  @State private var clockInDuration: String = "00:00"
  private let dateFormat: DateFormatter
  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  init(viewModel: CurrentTimeEntryViewModel) {
    self.viewModel = viewModel
    self.dateFormat = DateFormatter()
    dateFormat.dateFormat = "HH:mm"
  }
  
  private func startClockIn() {
    clockInDate = Date()
    clockInState = .ClockingIn
  }
  
  private func commitClockIn() {
    viewModel.start = clockInDate
    clockInState = .ClockedIn
  }
  
  private func startClockOut() {
    guard let newDate = Calendar.current.date(byAdding: .minute, value: 15, to: clockInDate) else {
      return
    }
    minClockOutDate = newDate
    clockOutDate = newDate
    clockInState = .ClockingOut
  }
  
  private func commitClockOut() {
    _ = viewModel.clockOut(at: clockOutDate)
    clockInState = .ClockedOut
  }
  
  private func updateClockInDuration(input: Date) {
    let components = Calendar.current.dateComponents([.hour, .minute], from: clockInDate, to: input)
    
    if let hour = components.hour, let minute = components.minute  {
      clockInDuration = "\(String(format: "%02d", hour)):\(String(format: "%02d", minute))"
    } else {
      clockInDuration = "00:00"
    }
  }
  
  var body: some View {
    VStack {
      Spacer()
      switch clockInState {
      case .ClockedOut:
        Text(" ")
        Button("Clock In...", action: startClockIn)
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .padding()
      case .ClockingIn:
        DatePicker("At", selection: $clockInDate, displayedComponents: [.date, .hourAndMinute])
          .datePickerStyle(.compact)
          .padding()
        Button("OK", action: commitClockIn)
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .padding()
      case .ClockedIn:
        Text(clockInDuration)
          .onAppear { updateClockInDuration(input: Date.now) }
          .onReceive(timer, perform: updateClockInDuration)
          .font(.system(size: 1000))
          .scaledToFit()
          .minimumScaleFactor(0.01)
          .lineLimit(1)
        Spacer()
        Text("Clocked in at \(self.dateFormat.string(from: clockInDate))")
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding()
        Button("Clock Out...", action: startClockOut)
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .padding()
      case .ClockingOut:
        DatePicker("At", selection: $clockOutDate, in: minClockOutDate..., displayedComponents: [.date, .hourAndMinute])
          .datePickerStyle(.compact)
          .padding()
        Button("OK", action: commitClockOut)
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .padding()
      }
    }
  }
}

struct CurrentTimeEntryView_Previews: PreviewProvider {
  static var previews: some View {
    let persistenceController = PersistenceController(inMemory: true)
    CurrentTimeEntryView(viewModel: CurrentTimeEntryViewModel(context: persistenceController.container.viewContext))
      .environment(\.managedObjectContext, persistenceController.container.viewContext)
  }
}
