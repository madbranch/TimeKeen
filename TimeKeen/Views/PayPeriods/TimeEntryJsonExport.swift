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
        .suggestedFileName { jsonExport in
            jsonExport.suggestFileName()
        }
    }
    
    func suggestFileName() -> String? {
        guard let suggestion = timeEntries.suggestFileNameWithoutExtension() else {
            return nil
        }
        
        return suggestion + ".json"
    }
}
