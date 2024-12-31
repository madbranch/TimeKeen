import Foundation
import SwiftUI
import AppIntents

enum WorkAction: String, AppEnum {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Work Action")
    
    static let caseDisplayRepresentations: [Self : DisplayRepresentation] = [
        .clockIn: "Clock In",
        .clockOut: "Clock Out",
        .startBreak: "Start Break",
        .endBreak: "End Break"
    ]
    
    case clockIn
    case clockOut
    case startBreak
    case endBreak
}

@Observable class QuickActionProvider {
    var quickAction: WorkAction?
}
