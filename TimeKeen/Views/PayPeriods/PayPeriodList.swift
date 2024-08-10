import SwiftUI

struct PayPeriodList: View {
  var viewModel: PayPeriodListViewModel
  @AppStorage(SharedData.Keys.payPeriodSchedule.rawValue, store: SharedData.userDefaults) var payPeriodSchedule = PayPeriodSchedule.Weekly
  @AppStorage(SharedData.Keys.endOfLastPayPeriod.rawValue, store: SharedData.userDefaults) var endOfLastPayPeriod = Calendar.current.date(from: DateComponents(year: 2024, month: 07, day: 21))!
  @State private var isPresentingShareSheet = false
  @State private var isEditingSettings = false
  
  init(viewModel: PayPeriodListViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    List(viewModel.payPeriods) { payPeriod in
      NavigationLink(value: payPeriod) {
        PayPeriodRow(viewModel: payPeriod)
      }
    }
    .navigationDestination(for: PayPeriodViewModel.self) { payPeriod in
      PayPeriodDetails(viewModel: payPeriod)
    }
    .onAppear() {
      viewModel.fetchTimeEntries(by: payPeriodSchedule, ending: endOfLastPayPeriod)
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Export", systemImage: "square.and.arrow.up") {
          isPresentingShareSheet = true
        }
      }
      ToolbarItem(placement: .topBarLeading) {
        Button("Grouping", systemImage: "slider.horizontal.3") {
          isEditingSettings = true
        }
      }
      ToolbarItem(placement: .topBarLeading) {
        Button("Donate", systemImage: "cup.and.saucer") {
          print("thx")
        }
      }
    }
    .overlay {
      if viewModel.payPeriods.isEmpty {
        ContentUnavailableView {
          Label("No Time Entries", systemImage: "clock")
        } description: {
          Text("Time you log will appear here.")
        }
      }
    }
    .sheet(isPresented: $isPresentingShareSheet) {
      TimeEntrySharingView(viewModel: viewModel.timeEntrySharingViewModel)
    }
    .sheet(isPresented: $isEditingSettings, onDismiss: refresh) {
      VStack {
        Text("Pay Periods")
          .font(.headline)
          .frame(maxWidth: .infinity, alignment: .center)
          .overlay(alignment: .trailing) {
            Button("OK") {
              isEditingSettings = false
            }
          }
        .padding([.bottom])
        Text("Choose how you want your time entries to be grouped.")
          .font(.subheadline)
        Picker("Schedule", selection: $payPeriodSchedule) {
          Text("Weekly").tag(PayPeriodSchedule.Weekly)
          Text("Biweekly").tag(PayPeriodSchedule.Biweekly)
          Text("Monthly").tag(PayPeriodSchedule.Monthly)
          Text("Every Four Weeks").tag(PayPeriodSchedule.EveryFourWeeks)
          Text("1st & 16th").tag(PayPeriodSchedule.FirstAndSixteenth)
        }
        if payPeriodSchedule == .FirstAndSixteenth {
          LabeledContent("Period Ends") {
            Text("Twice Monthly")
          }
        } else {
          DatePicker("Period Ends", selection: $endOfLastPayPeriod, displayedComponents: [.date] )
            .datePickerStyle(.compact)
        }
        Spacer()
      }
      .padding()
      .presentationDetents([.medium])
    }
  }
  
  func refresh() {
    viewModel.fetchTimeEntries(by: payPeriodSchedule, ending: endOfLastPayPeriod)
  }
}
