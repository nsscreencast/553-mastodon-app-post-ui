import Foundation

public struct Request<R: Resource> {
    public let path: String
    public let method: HTTPMethod
    public let params: HTTPParams?
    public let headers: [HTTPHeader]

    public init(
        path: String,
        method: HTTPMethod,
        params: HTTPParams? = nil,
        headers: [HTTPHeader] = []
    ) {
        self.path = path
        self.method = method
        self.params = params
        self.headers = headers
    }
}
