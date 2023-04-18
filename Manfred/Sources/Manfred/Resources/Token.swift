import Foundation

public class Token: Resource {
    public let accessToken: String
    public let tokenType: String
    public let scope: String
    public let createdAt: Date
}
