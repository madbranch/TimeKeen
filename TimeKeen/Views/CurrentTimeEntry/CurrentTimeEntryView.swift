import SwiftUI

struct CurrentTimeEntryView: View {
  @Environment(\.managedObjectContext) private var viewContext
  
  @ObservedObject var viewModel: CurrentTimeEntryViewModel
  
  @State private var clockInDuration: Duration = .zero
  
  @State private var isClockingIn = false
  @State private var isClockingOut = false
  @State private var clockInDate = Date()
  @State private var clockOutDate = Date()
  @State private var minClockOutDate = Date()
  
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
  
  var body: some View {
    VStack {
      switch viewModel.clockInState {
      case .ClockedOut:
        Button {
          clockInDate = Date()
          isClockingIn = true
        } label: {
          Text("Clock In...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .clipShape(Circle())
        .padding()
      case .ClockedIn:
        Spacer()
        Text(clockInDuration.formatted(CurrentTimeEntryView.durationStyle))
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
          _ = viewModel.clockOut(at: clockOutDate)
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
  }
}
