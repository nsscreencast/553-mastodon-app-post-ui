
public enum HTTPHeader {
    case contentType(String)
    case authorization(String)

    var key: String {
        switch self {
        case .contentType: return "Content-Type"
        case .authorization: return "Authorization"
        }
    }

    var value: String {
        switch self {
        case .contentType(let contentType): return contentType
        case .authorization(let value): return value
        }
    }
}
