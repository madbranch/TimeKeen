import SwiftUI

struct TimeEntryJsonExport: Transferable {
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
