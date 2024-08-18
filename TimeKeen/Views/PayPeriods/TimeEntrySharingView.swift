import SwiftUI

struct TimeEntrySharingView: View {
  @Environment(\.dismiss) private var dismiss
  @State var from = Date()
  @State var to = Date()
  @State var format = TimeEntryExportFormat.csv
  let timeEntries: [TimeEntry]
  
  init(timeEntries: [TimeEntry]) {
    self.timeEntries = timeEntries
  }
  
  var body: some View {
    VStack {
      Text("Export")
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .center)
        .overlay(alignment: .trailing) {
          Button("Cancel", role: .cancel) {
            dismiss()
          }
        }
        .padding([.bottom])
      Text("Export all time entries from the selected period in time.")
        .font(.subheadline)
      DatePicker("From", selection: $from, in: ...to, displayedComponents: [.date])
        .datePickerStyle(.compact)
      DatePicker("To", selection: $to, in: from..., displayedComponents: [.date])
        .datePickerStyle(.compact)
      LabeledContent("Format") {
        Picker("Format", selection: $format) {
          Text("CSV").tag(TimeEntryExportFormat.csv)
          Text("JSON").tag(TimeEntryExportFormat.json)
        }
      }
      Spacer()
      switch format {
      case .csv:
        ShareLink(item: TimeEntryCsvExport(timeEntries: timeEntries.filter { [from, to] in $0.start >= from && $0.start <= to }), preview: SharePreview("CSV Time Entries", image: Image(systemName: "tablecells"))) {
          Label("Export to CSV", systemImage: "square.and.arrow.up")
            .frame(maxWidth: .infinity)
        }
      case .json:
        ShareLink(item: TimeEntryJsonExport(timeEntries: timeEntries.filter { [from, to] in $0.start >= from && $0.start <= to }), preview: SharePreview("JSON Time Entries", image: Image(systemName: "doc.text"))) {
          Label("Export to JSON", systemImage: "square.and.arrow.up")
            .frame(maxWidth: .infinity)
        }
      }
    }
    .padding()
    .presentationDetents([.medium])
  }
}
