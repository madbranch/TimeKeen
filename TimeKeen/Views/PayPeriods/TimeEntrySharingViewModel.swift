import Foundation
import SwiftUI
import SwiftData

struct TimeEntryCsvExport: Transferable {
  static var transferRepresentation: some TransferRepresentation {
    DataRepresentation(exportedContentType: .commaSeparatedText) { csvExport in
      csvExport.viewModel.commaSeparatedText()
    }
  }
  
  unowned let viewModel: TimeEntrySharingViewModel
}

struct TimeEntryJsonExport: Transferable {
  static var transferRepresentation: some TransferRepresentation {
    DataRepresentation(exportedContentType: .json) { jsonExport in
      jsonExport.viewModel.json()
    }
  }
  
  unowned let viewModel: TimeEntrySharingViewModel
}

@Observable class TimeEntrySharingViewModel {
  private var context: ModelContext
  var from = Date()
  var to = Date()
  var format = TimeEntryExportFormat.csv
  var csvExport: TimeEntryCsvExport! = nil
  var jsonExport: TimeEntryJsonExport! = nil
  
  init(context: ModelContext) {
    self.context = context
    csvExport = TimeEntryCsvExport(viewModel: self)
    jsonExport = TimeEntryJsonExport(viewModel: self)
  }
  
  func commaSeparatedText() -> Data {
    do {
      let dateRange = from...to
      let descriptor = FetchDescriptor<TimeEntry>(predicate: #Predicate<TimeEntry> { dateRange.contains($0.start) }, sortBy: [SortDescriptor(\.start, order: .reverse)])
      let timeEntries = try context.fetch(descriptor)
      
      var text = String(localized: "From,To,Number of Breaks,On Break,On the Clock,Notes\n")
      
      let formatter = ISO8601DateFormatter()
      
      for timeEntry in timeEntries {
        text.append("\(formatter.string(from: timeEntry.start)),\(formatter.string(from: timeEntry.end)),\"\(timeEntry.notes)\"\n")
      }
      
      return Data()
    } catch {
      return Data()
    }
  }
  
  func json() -> Data {
    return Data()
  }
}
