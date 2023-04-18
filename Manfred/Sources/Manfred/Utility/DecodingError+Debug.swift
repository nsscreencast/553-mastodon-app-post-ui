import Foundation

extension DecodingError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .dataCorrupted(let context):           return "Data corrupted: \(context)"
        case .keyNotFound(let key, let context):    return "Key not found: \(key) \(context)"
        case .typeMismatch(let type, let context):  return "Type mismatch: \(type), \(context)"
        case .valueNotFound(let type, let context): return "Value not found: \(type), \(context)"
        @unknown default:
            return "Unknown error"
        }
    }
}
