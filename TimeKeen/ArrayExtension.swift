import Foundation

extension Array: @retroactive Identifiable where Element: Hashable {
    public var id: Self { self }
}

extension Array: @retroactive RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

extension Array where Element: TimeEntry {
    public func suggestFileNameWithoutExtension() -> String? {
        guard let first = self.first else {
            return nil
        }
        
        guard let last = self.last else {
            return nil
        }
        
        return "\(Formatting.fileNameDateFormatter.string(from: first.start)) - \(Formatting.fileNameDateFormatter.string(from: last.start)).csv"
    }
}
