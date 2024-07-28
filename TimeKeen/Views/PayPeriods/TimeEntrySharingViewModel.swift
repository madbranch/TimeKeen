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
      let calendar = Calendar.current
      let from = calendar.startOfDay(for: self.from)
      let to = calendar.startOfDay(for: calendar.nextDay(from: self.to)!)
      let descriptor = FetchDescriptor<TimeEntry>(predicate: #Predicate<TimeEntry> { $0.start >= from && $0.start < to }, sortBy: [SortDescriptor(\.start, order: .reverse)])
      let timeEntries = try context.fetch(descriptor)
      
      var text = String(localized: "From,To,Number of Breaks,On Break,On the Clock,Notes\n")
      
      let dateFormatter = ISO8601DateFormatter()
      
      for timeEntry in timeEntries {
        let from = dateFormatter.string(from: timeEntry.start)
        let to = dateFormatter.string(from: timeEntry.end)
        let numberOfBreaks = timeEntry.breaks.count
        let onBreak = Formatting.timeIntervalFormatter.string(from: timeEntry.onBreak) ?? ""
        let onTheClock = Formatting.timeIntervalFormatter.string(from: timeEntry.onTheClock) ?? ""
        text.append("\(from),\(to),\(numberOfBreaks),\(onBreak),\(onTheClock),\(timeEntry.notes)\n")
      }
      
      return Data(text.utf8)
    } catch {
      return Data()
    }
  }
  
  func json() -> Data {
    return Data()
  }
}
