import Foundation

public struct OAuthApplication: Resource {
    public let id: String
    public let name: String
    public let website: URL
    public let redirectUri: String
    public let clientId: String
    public let clientSecret: String
    public let vapidKey: String
}
