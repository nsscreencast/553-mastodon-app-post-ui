#if DEBUG
import SwiftUI
import Manfred

public extension Account {
    static var preview: Account {
        .init(
            id: "109551767400245819",
            username: "johnsundell",
            acct: "johnsundell@mastodon.social",
            displayName: "John Sundell",
            avatarStatic: URL(string: "https://files.mastodon.social/accounts/avatars/000/412/949/original/075307e8e9b51344.jpg")!
        )
    }

    static var previewSameServer: Account {
        .init(
            id: "123455741929039403",
            username: "johndoe",
            acct: "johndoe",
            displayName: "John Doe",
            avatarStatic: URL(string: "https://6-28.mastodon.xyz/cache/accounts/avatars/109/265/741/929/039/403/original/12a053db54bcfc17.jpeg")!
        )
    }
}

public extension Post {
    static var preview: Post {
        .init(
            id: UUID().uuidString,
            createdAt: Date(),
            content: FormattedContent(html: "<p>Got one more podcast to share with you before the holidays 😀</p><p>On the latest episode of Stacktrace, <span class=\"h-card\"><a href=\"https://mastodon.social/@_inside\" class=\"u-url mention\">@<span>_inside</span></a></span> and I talk about building computers, running A/B tests as an indie dev, using UIKit as a layout tool for SwiftUI views, and picking between different data storage solutions.</p><p>Hope you&#39;ll enjoy the episode 👍</p><p><a href=\"https://stacktracepodcast.fm/episodes/192\" target=\"_blank\" rel=\"nofollow noopener noreferrer\"><span class=\"invisible\">https://</span><span class=\"ellipsis\">stacktracepodcast.fm/episodes/</span><span class=\"invisible\">192</span></a></p>"),
            account: .preview,
            card: Post.Card(url: URL(string: "https://stacktracepodcast.fm/episodes/192")!)
        )
    }

    static var reblog: Post {
        .init(
            id: UUID().uuidString,
            createdAt: Date(),
            content: nil,
            account: .previewSameServer,
            card: nil,
            reblog: .init(.preview)
        )
    }

    static var image: Post {
        .init(
            id: UUID().uuidString,
            createdAt: Date(),
            content: nil,
            account: .preview,
            card: nil,
            media: [.squareImage]
        )
    }

    static var imageAspectRatios: Post {
        .init(
            id: UUID().uuidString,
            createdAt: Date(),
            content: FormattedContent(html: "<p>Pictures with varying aspect ratios.</p>"),
            account: .preview,
            card: nil,
            media: [
                .portraitImage,
                .landscapeImage,
                .landscapeImage2
            ]
        )
    }
}

public extension MediaAttachment {
    static let squareImage = MediaAttachment(
        id: "109841597016557294",
        type: .image,
        url: URL(string: "https://cdn.masto.host/rambomastohost/media_attachments/files/109/841/597/016/557/294/original/5c1bbfc8df337aa6.jpeg")!,
        previewUrl: URL(string: "https://cdn.masto.host/rambomastohost/media_attachments/files/109/841/597/016/557/294/small/5c1bbfc8df337aa6.jpeg")!,
        description: nil,
        blurhash: "UUDv[:RjMxWC.TNHt7WB?va#axogD*WXxuWV"
    )

    static let portraitImage = MediaAttachment(
        id: "109841572394019764",
        type: .image,
        url: URL(string: "https://cdn.masto.host/rambomastohost/media_attachments/files/109/841/572/394/019/764/original/8eccb16cdc99136e.jpeg")!,
        previewUrl: URL(string: "https://cdn.masto.host/rambomastohost/media_attachments/files/109/841/572/394/019/764/small/8eccb16cdc99136e.jpeg")!,
        description: nil,
        blurhash: "UBI}t,v|?wV?8^s+M{%g%$t78_WoMx.8bcDi"
    )

    static let landscapeImage = MediaAttachment(
        id: "109841572565749626",
        type: .image,
        url: URL(string: "https://cdn.masto.host/rambomastohost/media_attachments/files/109/841/572/565/749/626/original/5e83e84eec49fa68.jpeg")!,
        previewUrl: URL(string: "https://cdn.masto.host/rambomastohost/media_attachments/files/109/841/572/565/749/626/small/5e83e84eec49fa68.jpeg")!,
        description: nil,
        blurhash: "UPEx|c~WEQt6xW-n%2R.oMRkWAs,f,R*IUIU"
    )

    static let landscapeImage2 = MediaAttachment(
        id: "109841572641361736",
        type: .image,
        url: URL(string: "https://cdn.masto.host/rambomastohost/media_attachments/files/109/841/572/641/361/736/original/fffbb2123771ddb0.jpeg")!,
        previewUrl: URL(string: "https://cdn.masto.host/rambomastohost/media_attachments/files/109/841/572/641/361/736/small/fffbb2123771ddb0.jpeg")!,
        description: nil,
        blurhash: "USJaimaK~p9a?va}tRt6%LxunhR+NIj[s:s-"
    )

    static let video = MediaAttachment(
        id: "109841579746156230",
        type: .video,
        url: URL(string: "https://cdn.masto.host/rambomastohost/media_attachments/files/109/841/579/746/156/230/original/334485659f5babfe.mp4")!,
        previewUrl: URL(string: "https://cdn.masto.host/rambomastohost/media_attachments/files/109/841/579/746/156/230/small/334485659f5babfe.png")!,
        description: nil,
        blurhash: "ULIhNpnMoft601W?Rjt6NyX9oeogs,M|R+kC"
    )
}
#endif
