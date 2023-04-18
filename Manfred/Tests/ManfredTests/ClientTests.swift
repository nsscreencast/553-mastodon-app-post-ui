import Foundation
import XCTest
@testable import Manfred

extension Int: Resource {}

class ClientTests: XCTestCase {
    func testClientTakesBaseURL() {
        let client = Client(baseURL: URL("https://mastodon.social"))
        XCTAssertEqual(client.baseURL, URL("https://mastodon.social"))
    }

    func testClientSendsRequestWithQueryParams() async throws {
        var client = Client(baseURL: URL("https://mastodon.social"))
        let mockNetwork = MockNetworkAdapter()
        mockNetwork.expect("/foo/bar", andReturn: "1")

        client.adapter = mockNetwork
        let request = Request<Int>(path: "/foo/bar", method: .get, params: .queryString(["a": "b"]))

        _ = try await client.send(request)

        let sent = try XCTUnwrap(mockNetwork.requestsSent.last, "request wasn't sent")
        let components = try XCTUnwrap(URLComponents(url: sent.url!, resolvingAgainstBaseURL: false))
        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.host, "mastodon.social")
        XCTAssertEqual(components.path, "/foo/bar")
        XCTAssertEqual(components.query, "a=b")
    }

    func testLiveClient() async throws {
        var client = Client(baseURL: URL("https://mastodon.social"))
        client.adapter = client.adapter.logging(
            requests: .full, responses: .full
        )
        _ = try await client.send(Timeline.public(params: [:]))
    }
}
