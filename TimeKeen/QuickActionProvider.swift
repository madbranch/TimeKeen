import Foundation
import SwiftUI

enum QuickAction: String {
    case clockIn
    case clockOut
    case startBreak
    case endBreak
}

@Observable class QuickActionProvider {
    var quickAction: QuickAction?
}
