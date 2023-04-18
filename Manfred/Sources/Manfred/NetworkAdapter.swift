import Foundation

public protocol NetworkAdapter {
    func send(request: URLRequest) async throws -> (body: Data, status: Int, headers: [AnyHashable: Any])
}

extension NetworkAdapter {
    public func logging(
        requests: LoggingNetworkAdapter.LogLevel = .summary,
        responses: LoggingNetworkAdapter.LogLevel = .summary
    ) -> LoggingNetworkAdapter {
        .init(requests: requests, responses: responses, wrapping: self)
    }
}

extension NetworkAdapter where Self == LiveNetworkAdapter {
    public static func live(session: URLSession = .shared) -> Self {
        LiveNetworkAdapter(session: session)
    }
}

public struct LoggingNetworkAdapter: NetworkAdapter {
    public enum LogLevel {
        case none
        case summary
        case full
    }

    private let requestLogLevel: LogLevel
    private let responseLogLevel: LogLevel
    private let wrapped: any NetworkAdapter
    private let sizeFormatter = ByteCountFormatter()

    public init(
        requests: LogLevel = .summary,
        responses: LogLevel = .summary,
        wrapping inner: some NetworkAdapter
    ) {
        self.requestLogLevel = requests
        self.responseLogLevel = responses
        self.wrapped = inner
    }

    public func send(request: URLRequest) async throws -> (body: Data, status: Int, headers: [AnyHashable : Any]) {
        do {
            logRequest(request)
            let response = try await wrapped.send(request: request)
            logResponse(request: request, response: response)
            return response
        } catch {
            logError(request, error)
            throw error
        }
    }

    private func logRequest(_ request: URLRequest) {
        if requestLogLevel == .none {
            return
        }

        print("HTTP Request to \(request.url!)")

        if requestLogLevel == .full, let body = request.httpBody {
            let bodyString = String(decoding: body, as: UTF8.self)
            print("Request body:\n----------------------\(bodyString)\n----------------------")
        }
    }

    private func logError(_ request: URLRequest, _ error: Error) {
        if responseLogLevel == .none {
            return
        }

        print("Request to \(request.url!) failed with error:")
        print(error)
    }

    private func logResponse(request: URLRequest, response: (body: Data, status: Int, headers: [AnyHashable: Any])) {
        if responseLogLevel == .none {
            return
        }

        let formattedSize = sizeFormatter.string(fromByteCount: Int64(response.body.count))
        print("Received HTTP \(response.status) from \(request.url!) (\(formattedSize))")

        if responseLogLevel == .full {
            var bodyString = String(decoding: response.body, as: UTF8.self)
            let maxLogLength = 10_000
            if bodyString.count > maxLogLength {
                bodyString = String(bodyString[..<bodyString.index(bodyString.startIndex, offsetBy: maxLogLength)]) + "…"
            }
            print("Response:\n----------------------\(bodyString)\n----------------------")
        }
    }
}

public struct LiveNetworkAdapter: NetworkAdapter {
    let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func send(request: URLRequest) async throws -> (body: Data, status: Int, headers: [AnyHashable: Any]) {
        let (data, response) = try await session.data(for: request, delegate: nil)

        return (
            body: data,
            status: (response as! HTTPURLResponse).statusCode,
            headers: [:]
        )
    }
}
