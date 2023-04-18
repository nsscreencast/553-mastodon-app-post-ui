import SwiftUI

struct PostView: View {
    var post: Post
    var booster: Account?

    init(post: Post) {
        self.post = post.displayPost
        if post.reblog != nil {
            booster = post.account
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(post.account.displayName)
                    .font(.headline)

                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    let c = post.account.formattedUsernameComponents
                    Text(c.handle)
                        .foregroundStyle(.secondary)
                    if let server = c.server {
                        Text(server)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            if let content = post.content {
                Text(content.attributedString)
            } else {
                Text("(This post doesn't have content)")
                    .foregroundColor(.red)
            }
        }
    }
}

#if DEBUG
struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(post: .reblog)
            .frame(width: 300)
            .padding()
    }
}
#endif
