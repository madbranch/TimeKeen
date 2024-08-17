import SwiftUI

struct TimeEntryList: View {
  @Environment(\.modelContext) private var context
  @Environment(\.dismiss) private var dismiss
  @State var timeEntries: [TimeEntry]

  init(timeEntries: [TimeEntry]) {
    self.timeEntries = timeEntries
  }
  
  var body: some View {
    ForEach(timeEntries) { timeEntry in
      NavigationLink(value: timeEntry) {
        TimeEntryRow(timeEntry: timeEntry)
      }
    }
    .onDelete { offsets in
      for index in offsets {
        context.delete(timeEntries[index])
      }
      timeEntries.remove(atOffsets: offsets)

      if timeEntries.isEmpty {
        dismiss()
      }
    }
  }
}
