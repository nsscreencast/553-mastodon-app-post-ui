import Foundation

public struct Account: Resource, Equatable, Hashable {
    public let id: String
    public let username: String
    public let acct: String
    public let displayName: String
    public let locked: Bool
    public let bot: Bool
    public let discoverable: Bool?
    public let group: Bool
    public let createdAt: Date
    public let note: String
    public let url: URL
    public let avatar: URL
    public let avatarStatic: URL
    public let header: URL
    public let headerStatic: URL
    public let followersCount: Int
    public let followingCount: Int
    public let statusesCount: Int

    @DateFormat(YearMonthDay.self)
    public var lastStatusAt: Date?

//    public let emojis:[]
//    public let fields:[]
}
