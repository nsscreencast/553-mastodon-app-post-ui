import SwiftUI
import Manfred

@MainActor
final class TimelineController: ObservableObject {
    let session: Session

    init(session: Session) {
        self.session = session
        self.statuses = []
        self.state = .empty
    }

    @Published private(set) var statuses: [Status]

    enum State {
        case empty
        case loading
        case loaded
    }

    @Published private(set) var state: State

    func fetchPosts() async {
        // max_id, min_id
        self.state = .loading
        do {
            let statuses = try await session.client.send(
                Timeline.home(accessToken: session.accessToken, params: [String : String]())
            )
            self.statuses += statuses
            self.state = .loaded
        } catch {
            NSAlert(error: error).runModal()
        }
    }
}
