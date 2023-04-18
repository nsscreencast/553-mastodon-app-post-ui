import Foundation

public class Status: Resource, IdReferenceEquatable, Hashable {
    public let id: String
    public let createdAt: Date
    public let inReplyToId: String?
    public let inReplyToAccountId: String?
    public let sensitive: Bool
    public let spoilerText: String
    public let visibility: Visibility
    public let language: String?
    public let uri: URL
    public let url: URL?
    public let repliesCount: Int
    public let reblogsCount: Int
    public let favouritesCount: Int
    public let editedAt: Date?
    public let content: String
    public let reblog: Status?
    public let account: Account
    public let mediaAttachments: [MediaAttachment]

    public func hash(into hasher: inout Hasher) {
        hasher.combine("Status")
        hasher.combine(id)
    }
}

public extension Status {
    var favoritesCount: Int { favouritesCount }
}

public enum Visibility: String, Codable {
    case `public`
    case unlisted
    case `private`
    case direct
}
