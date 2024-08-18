import SwiftUI

struct TimeEntryCsvExport: Transferable {
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
