import Foundation
import Manfred

class MockNetworkAdapter: NetworkAdapter {
    var requestsSent: [URLRequest] = []

    private var mockResponses: [String: String] = [:]

    func send(request: URLRequest) async throws -> (body: Data, status: Int, headers: [AnyHashable: Any]) {
        requestsSent.append(request)

        let data: Data
        if let mockResponse = mockResponses[request.url!.relativePath] {
            data = Data(mockResponse.utf8)
        } else {
            data = Data()
        }

        return (
            body: data,
            status: 200,
            headers: [:]
        )
    }

    func expect(_ path: String, andReturn body: String) {
        mockResponses[path] = body
    }
}
