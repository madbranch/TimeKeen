import SwiftUI
import SwiftData
import StoreKit

struct PayPeriodList: View {
  @AppStorage(SharedData.Keys.payPeriodSchedule.rawValue, store: SharedData.userDefaults) var payPeriodSchedule = PayPeriodSchedule.Weekly
  @AppStorage(SharedData.Keys.endOfLastPayPeriod.rawValue, store: SharedData.userDefaults) var endOfLastPayPeriod = Calendar.current.date(from: DateComponents(year: 2024, month: 07, day: 21))!
  @Query(sort: \TimeEntry.start, order: .reverse) var allTimeEntries: [TimeEntry]
  @State private var isPresentingShareSheet = false
  @State private var isEditingSettings = false
  
  var body: some View {
    List(allTimeEntries.group(by: payPeriodSchedule, ending: endOfLastPayPeriod)) { payPeriod in
      NavigationLink(value: payPeriod) {
        PayPeriodRow(payPeriod: payPeriod)
      }
    }
    .navigationDestination(for: PayPeriod.self) { payPeriod in
      PayPeriodDetails(for: payPeriod.range)
    }
    .navigationDestination(for: TimeEntry.self) { timeEntry in
      TimeEntryDetails(for: timeEntry)
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Export", systemImage: "square.and.arrow.up") {
          isPresentingShareSheet = true
        }
      }
      ToolbarItem(placement: .topBarLeading) {
        Button("Grouping", systemImage: "gear") {
          isEditingSettings = true
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
      timeEntrySharingSheet
    }
    .sheet(isPresented: $isEditingSettings) {
      PayPeriodSettingsSheet()
    }
  }
  
  var timeEntrySharingSheet: some View {
    NavigationStack {
      TimeEntrySharingView(timeEntries: allTimeEntries, defaultRange: (allTimeEntries.first?.start ?? Date()).getPayPeriod(schedule: payPeriodSchedule, periodEnd: endOfLastPayPeriod))
        .background(.background.secondary)
        .navigationTitle("Export")
        .toolbar {
          ToolbarItem(placement: .confirmationAction) {
            Button("Done") {
              isPresentingShareSheet = false
            }
          }
        }
    }
    .presentationDetents([.medium])
  }
}
