import Foundation

public enum Accounts {
    public static func get(
        accessToken: String?,
        id: String
    ) -> Request<Account> {
        var headers: [HTTPHeader] = []
        if let accessToken {
            headers.append(.authorization("Bearer \(accessToken)"))
        }
        return Request(path: "/api/v1/account/\(id)",
                method: .get,
                headers: headers
        )
    }

    public static func me(accessToken: String) -> Request<Account> {
        Request(path: "/api/v1/accounts/verify_credentials",
                method: .get,
                headers: [.authorization("Bearer \(accessToken)")])
    }
}
