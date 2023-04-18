import SwiftUI
import Manfred

struct MastodonTimelineView: View {
    @ObservedObject var controller: TimelineController

    var body: some View {
        TimelinePostsView(posts: controller.statuses.map(Post.init))
        .task {
            await controller.fetchPosts()
        }
    }
}

struct TimelinePostsView: View {
    var posts: [Post]

    var body: some View {
        List {
            ForEach(posts) { post in
                PostView(post: post)
            }
        }
    }
}

#if DEBUG
struct TimelinePostsView_Previews: PreviewProvider {
    static var previews: some View {
        TimelinePostsView(posts: [
            .preview
        ])
        .frame(width: 300)
    }
}
#endif
