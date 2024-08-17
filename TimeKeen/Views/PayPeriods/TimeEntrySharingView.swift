import SwiftUI

struct TimeEntryCsvExport2: Transferable {
  let timeEntries: [TimeEntry]
  
  static var transferRepresentation: some TransferRepresentation {
    DataRepresentation(exportedContentType: .commaSeparatedText) { csvExport in
      var text = String(localized: "From,To,Number of Breaks,On Break,On the Clock,Notes\n")
      let dateFormatter = ISO8601DateFormatter()
      
      for timeEntry in csvExport.timeEntries {
        let from = dateFormatter.string(from: timeEntry.start)
        let to = dateFormatter.string(from: timeEntry.end)
        let numberOfBreaks = timeEntry.breaks.count
        let onBreak = Formatting.timeIntervalFormatter.string(from: timeEntry.onBreak) ?? ""
        let onTheClock = Formatting.timeIntervalFormatter.string(from: timeEntry.onTheClock) ?? ""
        text.append("\(from),\(to),\(numberOfBreaks),\(onBreak),\(onTheClock),\(timeEntry.notes)\n")
      }
      
      return Data(text.utf8)
    }
  }
}

struct TimeEntryJsonExport2: Transferable {
  let timeEntries: [TimeEntry]
  
  static var transferRepresentation: some TransferRepresentation {
    DataRepresentation(exportedContentType: .json) { jsonExport in
      do {
        let encodedData = try JSONEncoder().encode(jsonExport.timeEntries)
        return Data(encodedData)
      } catch {
        return Data()
      }
    }
  }
}

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
        ShareLink(item: TimeEntryCsvExport2(timeEntries: timeEntries.filter { [from, to] in $0.start >= from && $0.start <= to }), preview: SharePreview("CSV Time Entries", image: Image(systemName: "tablecells"))) {
          Label("Export to CSV", systemImage: "square.and.arrow.up")
            .frame(maxWidth: .infinity)
        }
      case .json:
        ShareLink(item: TimeEntryJsonExport2(timeEntries: timeEntries.filter { [from, to] in $0.start >= from && $0.start <= to }), preview: SharePreview("JSON Time Entries", image: Image(systemName: "doc.text"))) {
          Label("Export to JSON", systemImage: "square.and.arrow.up")
            .frame(maxWidth: .infinity)
        }
      }
    }
    .padding()
    .presentationDetents([.medium])
  }
}
