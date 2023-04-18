import Foundation

enum ClientError: Error, CustomStringConvertible {
    case requestFailed(status: Int, body: Data)

    var description: String {
        switch self {
        case .requestFailed(status: let status, body: let body):
            return """
                   Request Failed (HTTP \(status))
                   Response body:
                   ---------
                   \(String(decoding: body, as: UTF8.self))
                   ---------
                   """
        }
    }
}

public struct Client {
    public let baseURL: URL
    public var adapter: NetworkAdapter

    private let defaultDecoder = JSONDecoder.mastodon

    public init(baseURL: URL, adapter: NetworkAdapter? = nil) {
        self.baseURL = baseURL
        self.adapter = adapter ?? LiveNetworkAdapter()
    }

    public func send<R: Resource>(_ request: Request<R>) async throws -> R {
        let (data, status, _) = try await adapter.send(request: .build(from: request, baseURL: baseURL))

        if status != 200 {
            throw ClientError.requestFailed(status: status, body: data)
        }

        do {
            return try defaultDecoder.decode(R.self, from: data)
        } catch let error as DecodingError {
            #if DEBUG
            print("---------------------------------------------------------------")
            print(String(decoding: data, as: UTF8.self))
            print("---------------------------------------------------------------")
            #endif
            print(error.debugDescription)
            throw error
        }
    }
}

private extension URLRequest {
    static func build<R: Resource>(from request: Request<R>, baseURL: URL) -> Self {
        var components = URLComponents()
        components.path = request.path

        if case .queryString(let query) = request.params {
            components.queryItems = query.map(URLQueryItem.init)
        }

        // assume for now that all urls will be valid
        let url = components.url(relativeTo: baseURL)!

        var req = URLRequest(url: url)
        req.httpMethod = request.method.rawValue

        // don't be opinionated about whether body is allowed here, we assume callers
        // know what they're doing
        if case .httpBody(let data) = request.params {
            req.httpBody = data
        }

        req.setValue("Manfred 0.1 (Swift mastodon client)", forHTTPHeaderField: "User-Agent")
        request.headers.forEach { header in
            req.setValue(header.value, forHTTPHeaderField: header.key)
        }

        return req
    }
}
