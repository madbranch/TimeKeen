import Foundation
import SwiftData

@Model
class BreakEntry: Encodable {
  init(start: Date, end: Date) {
    self.start = start
    self.end = end
  }
  var start: Date
  var end: Date
  
  enum CodingKeys: String, CodingKey {
    case start, end
  }
  
  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(start, forKey: .start)
    try container.encode(end, forKey: .end)
  }
}
