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

struct CurrentTimeEntryView: View {
  @Environment(\.managedObjectContext) private var viewContext
  
  @ObservedObject var viewModel: CurrentTimeEntryViewModel

  @State private var clockInDuration: String = "00:00"

  private let dateFormat: DateFormatter
  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  init(viewModel: CurrentTimeEntryViewModel) {
    self.viewModel = viewModel
    dateFormat = DateFormatter()
    dateFormat.dateFormat = "HH:mm"
  }
  
  private func updateClockInDuration(input: Date) {
    let components = Calendar.current.dateComponents([.hour, .minute], from: viewModel.clockInDate, to: input)
    
    if let hour = components.hour, let minute = components.minute  {
      clockInDuration = "\(String(format: "%02d", hour)):\(String(format: "%02d", minute))"
    } else {
      clockInDuration = "00:00"
    }
  }
  
  var body: some View {
    VStack {
      Spacer()
      switch viewModel.clockInState {
      case .ClockedOut:
        Button("Clock In...", action: viewModel.startClockIn)
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .padding()
      case .ClockingIn:
        DatePicker("At", selection: $viewModel.clockInDate, displayedComponents: [.date, .hourAndMinute])
          .datePickerStyle(.compact)
          .padding()
        Button("Clock In at \(self.dateFormat.string(from: viewModel.clockInDate))", action: viewModel.commitClockIn)
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
        Text("Clocked in at \(self.dateFormat.string(from: viewModel.clockInDate))")
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding()
        Button("Clock Out...", action: viewModel.startClockOut)
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          .padding()
      case .ClockingOut:
        DatePicker("At", selection: $viewModel.clockOutDate, in: viewModel.minClockOutDate..., displayedComponents: [.date, .hourAndMinute])
          .datePickerStyle(.compact)
          .padding()
        Button("Clock Out at \(self.dateFormat.string(from: viewModel.clockOutDate))", action: viewModel.commitClockOut)
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
