import SwiftUI
import SwiftData
import StoreKit

struct PayPeriodList: View {
  var viewModel: PayPeriodListViewModel
  @AppStorage(SharedData.Keys.payPeriodSchedule.rawValue, store: SharedData.userDefaults) var payPeriodSchedule = PayPeriodSchedule.Weekly
  @AppStorage(SharedData.Keys.endOfLastPayPeriod.rawValue, store: SharedData.userDefaults) var endOfLastPayPeriod = Calendar.current.date(from: DateComponents(year: 2024, month: 07, day: 21))!
  @Query(sort: \TimeEntry.start, order: .reverse) var allTimeEntries: [TimeEntry]
  @State private var isPresentingShareSheet = false
  @State private var isEditingSettings = false
  @State private var isShopping = false
  
  init(viewModel: PayPeriodListViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    List(allTimeEntries.group2(by: payPeriodSchedule, ending: endOfLastPayPeriod)) { payPeriod in
      NavigationLink(value: payPeriod) {
        HStack {
          VStack(alignment: .leading) {
            Text("\(Formatting.yearlessDateformatter.string(from: payPeriod.range.lowerBound)) - \(Formatting.yearlessDateformatter.string(from: payPeriod.range.upperBound))")
              .font(.headline)
            Text(payPeriod.timeEntries.count == 1 ? "1 entry" : "\(payPeriod.timeEntries.count) entries")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
          Spacer()
          Text(Formatting.timeIntervalFormatter.string(from: payPeriod.timeEntries.reduce(TimeInterval()) { $0 + $1.onTheClock }) ?? "")
            .foregroundStyle(.secondary)
        }
      }
    }
    .navigationDestination(for: PayPeriod.self) { payPeriod in
      PayPeriodDetails(payPeriod: payPeriod)
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
        Button("Tip Jar", systemImage: "storefront") {
          isShopping = true
        }
      }
    }
    .overlay {
      if allTimeEntries.isEmpty {
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
    .sheet(isPresented: $isEditingSettings) {
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
    .sheet(isPresented: $isShopping) {
      TipPickerSheet()
    }
  }
}
