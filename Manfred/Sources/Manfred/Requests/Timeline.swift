public struct Timeline {
    public static func `public`(params: [String: String]) -> Request<[Status]> {
        Request(path: "/api/v1/timelines/public", method: .get, params: .queryString(params))
    }

    public static func home(accessToken: String, params: [String: String]) -> Request<[Status]> {
        Request(path: "/api/v1/timelines/home",
                method: .get,
                params: .queryString(params),
                headers: [
                    .authorization("Bearer \(accessToken)")
                ]
        )
    }
}
