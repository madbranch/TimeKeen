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
    return Data()
  }
  
  func json() -> Data {
    return Data()
  }
}
