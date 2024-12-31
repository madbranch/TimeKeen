import SwiftUI

enum ColorPalette {
    case primary
    case secondary
    
    var color: Color {
        switch self {
        case .primary: return Color(red: 31/255, green: 126/255, blue: 161/255)
        case .secondary: return Color(red: 111/255, green: 247/255, blue: 232/255)
        }
    }
}

