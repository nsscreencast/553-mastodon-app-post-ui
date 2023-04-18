import Foundation

public enum Apps {
    public static func create(
        name: String,
        scopes: String,
        website: URL,
        redirectURI: String
    ) -> Request<OAuthApplication> {
        struct Payload: Encodable {
            let client_name: String
            let scopes: String
            let website: String
            let redirect_uris: String
        }
        let payload = Payload(client_name: name, scopes: scopes, website: website.absoluteString, redirect_uris: redirectURI)
        let data = (try? JSONEncoder().encode(payload)) ?? Data()
        return Request(
            path: "/api/v1/apps",
            method: .post,
            params: .httpBody(data),
            headers: [
                .contentType("application/json")
            ])
    }
}
