import SwiftUI
import SwiftData

enum PayPeriodListValue {
    case payPeriodList
}

extension ClosedRange: Identifiable where Bound == Date  {
    public var id: Self { self }
}

struct ContentView: View {
    var quickActionProvider: QuickActionProvider
    @State private var path: NavigationPath = .init()
    @AppStorage(SharedData.Keys.minuteInterval.rawValue, store: SharedData.userDefaults) var minuteInterval = 15
    @Environment(\.modelContext) private var context
    @State private var isEditingSettings = false
    @State private var payPeriod: ClosedRange<Date>?
    
    init(quickActionProvider: QuickActionProvider) {
        self.quickActionProvider = quickActionProvider
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            CurrentTimeEntryView(quickActionProvider: quickActionProvider, navigate: navigate)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Settings", systemImage: "gear") {
                            isEditingSettings = true
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(value: PayPeriodListValue.payPeriodList, label: {
                            Label("Time Sheets", systemImage: "list.bullet.rectangle")
                        })
                        .accessibilityIdentifier("TimeSheetsButton")
                    }
                }
                .navigationDestination(for: PayPeriodListValue.self) { _ in
                    PayPeriodList()
                }
                .navigationDestination(for: PayPeriod.self) { payPeriod in
                    PayPeriodDetails(for: payPeriod.range)
                }
                .navigationDestination(for: TimeEntry.self) { timeEntry in
                    TimeEntryDetails(for: timeEntry)
                }
                .sheet(isPresented: $isEditingSettings) {
                    PayPeriodSettingsSheet()
                }
                .sheet(item: $payPeriod) { payPeriod in
                    NavigationStack {
                        PayPeriodDetails(for: payPeriod)
                            .navigationDestination(for: TimeEntry.self) { timeEntry in
                                TimeEntryDetails(for: timeEntry)
                            }
                            .toolbar {
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("Done") {
                                        self.payPeriod = nil
                                    }
                                }
                            }
                    }
                }
        }
        .onAppear {
            UIDatePicker.appearance().minuteInterval = minuteInterval
        }
    }
    
    func navigate(to range: ClosedRange<Date>) {
        payPeriod = range
    }
}
