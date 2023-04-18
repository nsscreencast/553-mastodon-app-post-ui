import Foundation

public enum HTTPParams {
    case queryString([String: String])
    case httpBody(Data)
}
