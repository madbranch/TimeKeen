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
  
  init(viewModel: CurrentTimeEntryViewModel) {
    self.viewModel = viewModel
  }
  
  private func startClockIn() {
    clockInState = .ClockingIn
  }
  
  private func commitClockIn() {
    viewModel.start = clockInDate
    clockInState = .ClockedIn
  }
  
  private func startClockOut() {
    clockInState = .ClockingOut
  }
  
  private func commitClockOut() {
    let clockOutResult: Result<TimeEntry, ClockOutError> = viewModel.clockOut(at: clockOutDate)
    
    switch (clockOutResult) {
    case .success(let entry):
      print(entry)
    case .failure(let error):
      print(error)
    }
    
    clockInState = .ClockedOut
  }
  
  var body: some View {
    NavigationView {
      VStack {
        switch clockInState {
        case .ClockedOut:
          Button("Clock In...", action: startClockIn)
            .padding()
            .buttonStyle(ClockInButtonStyle())
        case .ClockingIn:
          DatePicker("At", selection: $clockInDate, displayedComponents: [.date, .hourAndMinute])
            .datePickerStyle(.compact)
          Button("OK", action: commitClockIn)
        case .ClockedIn:
          Button("Clock Out...", action: startClockOut)
            .padding()
            .buttonStyle(ClockInButtonStyle())
        case .ClockingOut:
          DatePicker("At", selection: $clockOutDate, displayedComponents: [.date, .hourAndMinute])
            .datePickerStyle(.compact)
          Button("OK", action: commitClockOut)
        }
      }
      .navigationTitle("Time Keen")
      .toolbar {
        ToolbarItem(placement: .bottomBar) {
          Button {
          } label: {
            Image(systemName: "gear")
          }
        }
        ToolbarItem(placement: .status) {
          Button {
          } label: {
            Image(systemName: "plus")
          }
        }
        ToolbarItem(placement: .bottomBar) {
          Button {
          } label: {
            Image(systemName: "list.bullet")
          }
        }
      }
    }
    .padding()
    .onAppear {
      UIDatePicker.appearance().minuteInterval = 15
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
