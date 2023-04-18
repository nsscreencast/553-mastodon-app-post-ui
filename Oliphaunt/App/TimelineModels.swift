import SwiftUI
import Manfred

public struct Account: Equatable {
    let id: String          // "123454741929039403"
    let username: String    // "johndoe",
    let acct: String        // "johndoe@example.social",
    let displayName: String // display_name": "John Doe",
    let avatarStatic: URL
}

extension Account {
    public init(manfredAccount: Manfred.Account) {
        self.id = manfredAccount.id
        self.username = manfredAccount.username
        self.acct = manfredAccount.acct
        self.displayName = manfredAccount.displayName
        self.avatarStatic = manfredAccount.avatarStatic
    }
}

public extension Account {
    /// Returns the user's handle and server as separate components.
    /// If the account belongs to the same server the current user belongs to,
    /// then the server component will be `nil`, in which case it shouldn't be displayed.
    var usernameComponents: (handle: String, server: String?) {
        let components = acct.components(separatedBy: "@")
        guard components.count > 1 else { return (acct, nil) }
        return (components[0], components[1])
    }

    /// Returns the user's handle and server as separate components,
    /// formatted appropriately with the leading `@` sign.
    /// See ``usernameComponents`` for more details.
    var formattedUsernameComponents: (handle: String, server: String?) {
        let components = usernameComponents
        if let server = components.server {
            return (components.handle, "@" + server)
        } else {
            return ("@" + components.handle, nil)
        }
    }
}

public struct Post: Equatable, Identifiable {
    public struct Card: Equatable {
        let url: URL
    }

    public let id: String
    let createdAt: Date
    let content: FormattedContent?
    let account: Account
    var card: Card? = nil
    var media: [Manfred.MediaAttachment] = []
    var reblog: Box<Post>?

    var displayPost: Post {
        reblog?.wrapped ?? self
    }
}

public class Box<T> {
    let wrapped: T

    init(_ wrapped: T) {
        self.wrapped = wrapped
    }
}

extension Box: Equatable where T: Equatable {
    public static func == (lhs: Box<T>, rhs: Box<T>) -> Bool {
        lhs.wrapped == rhs.wrapped
    }
}

public extension Post {
    init(status: Manfred.Status) {
        self.id = status.id
        self.createdAt = status.createdAt
        self.content = status.content.isEmpty ? nil : FormattedContent(html: status.content)
        self.account = .init(manfredAccount: status.account)
        self.card = nil // ??
        self.reblog = status.reblog.flatMap { reblog in
            Box(Post(status: reblog))
        }
        self.media = status.mediaAttachments
    }
}

public struct FormattedContent: Equatable {
    public let plainText: String
    public let attributedString: AttributedString

    public init(html: String) {
        if let attributedString = AttributedString(mastodonHTML: html) {
            self.attributedString = attributedString
        } else {
            assertionFailure("Failed to parse Mastodon HTML: \(html)")
            self.attributedString = AttributedString(html)
        }

        self.plainText = html
    }
}
