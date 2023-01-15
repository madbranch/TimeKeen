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
  private let dateFormat: DateFormatter
  
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
  
  var body: some View {
    VStack {
      Spacer()
      switch clockInState {
      case .ClockedOut:
        Text(" ")
        Button("Clock In...", action: startClockIn)
          .padding()
          .buttonStyle(ClockInButtonStyle())
      case .ClockingIn:
        DatePicker("At", selection: $clockInDate, displayedComponents: [.date, .hourAndMinute])
          .datePickerStyle(.compact)
        Button("OK", action: commitClockIn)
      case .ClockedIn:
        Text("Clocked in at \(self.dateFormat.string(from: clockInDate))")
        Button("Clock Out...", action: startClockOut)
          .padding()
          .buttonStyle(ClockInButtonStyle())
      case .ClockingOut:
        DatePicker("At", selection: $clockOutDate, in: minClockOutDate..., displayedComponents: [.date, .hourAndMinute])
          .datePickerStyle(.compact)
        Button("OK", action: commitClockOut)
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
