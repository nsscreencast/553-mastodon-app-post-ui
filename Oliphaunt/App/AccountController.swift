import SwiftUI
import KeychainAccess
import Manfred
import AuthenticationServices

struct Session {
    let accessToken: String
    let client: Client
}

class AccountController: ObservableObject {
    static let redirectURI = "oliphaunt://oauth_callback"
    let keychain = Keychain(service: "com.ficklebits.oliphaunt")

    private var authenticationSession: ASWebAuthenticationSession?

    @Published var session: Session?

    func selectServer(_ server: String) {
        guard let url = URL(string: "https://\(server)") else { return }

        let client = Client(
            baseURL: url,
            adapter: .live().logging(
                requests: .summary,
                responses: .full
            )
        )

        Task { @MainActor in
            do {
                let app = try await findOrCreateAppCredentials(with: client)

                lastUsedServer = server

                authenticationSession = .init(
                    url: authorizeURL(baseURL: client.baseURL, appCredentials: app),
                    callbackURLScheme: "oliphaunt_app",
                    completionHandler: { callbackURL, error in
                        Task { @MainActor in
                            if let error {
                                NSAlert(error: error).runModal()
                                return
                            }

                            guard
                                let callbackURL,
                                let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)
                            else {
                                return
                            }

                            guard let code = components.queryItems?.first(where: {
                                $0.name == "code"
                            })?.value else {
                                assertionFailure("Couldn't find code from callback URL: \(callbackURL)")
                                return
                            }

                            try await self.processOAuthCallback(
                                client: client,
                                authorizationCode: code,
                                appCredentials: app
                            )
                        }
                    })

                authenticationSession?.presentationContextProvider = NSApplication.shared
                authenticationSession?.start()

            } catch {
                NSAlert(error: error).runModal()
            }
        }
    }

    private func processOAuthCallback(
        client: Client,
        authorizationCode: String,
        appCredentials: AppCredentials
    ) async throws {
        struct TokenParams: Codable {
            let client_id: String
            let client_secret: String
        }

        let tokenParams: [String: String] = [
            "client_id": appCredentials.clientID,
            "client_secret": appCredentials.clientSecret,
            "grant_type": "authorization_code",
            "redirect_uri": Self.redirectURI,
            "scope": "read write follow push",
            "code": authorizationCode
        ]

        let formEncodedParams = tokenParams
            .map { key, value in
                "\(key)=\(value)"
            }
            .joined(separator: "&")

        let token = try await client.send(
            Request<Token>(
                path: "/oauth/token",
                method: .post,
                params: .httpBody(Data(formEncodedParams.utf8))
            )
        )

        let userID = UUID().uuidString
        lastUsedUserID = userID
        let key = KeychainScope.user(identifier: userID).key(for: client.baseURL)
        keychain.saveEncodedValue(token, for: key)

        await MainActor.run {
            withAnimation(.oliphaunt) {
                self.session = .init(accessToken: token.accessToken, client: client)
            }
        }
    }

    private var lastUsedServer: String? {
        get {
            UserDefaults.standard.string(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }

    private var lastUsedUserID: String? {
        get {
            UserDefaults.standard.string(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }

    func authorizeURL(baseURL: URL, appCredentials: AppCredentials) -> URL {
        baseURL
            .appending(path: "/oauth/authorize")
            .appending(queryItems: [
                .init(name: "response_type", value: "code"),
                .init(name: "client_id", value: appCredentials.clientID),
                .init(name: "scope", value: "read+write+follow+push"),
                .init(name: "redirect_uri", value: Self.redirectURI)
            ])
    }

    private func findOrCreateAppCredentials(with client: Client) async throws -> AppCredentials {
        let appKeychainKey = KeychainScope.app.key(for: client.baseURL)
        if let existingCredentials = keychain.decodeValue(AppCredentials.self, for: appKeychainKey) {
            return existingCredentials
        }

        let app = try await client.send(
            Apps.create(name: "Oliphaunt",
                        scopes: "read write follow push",
                        website: URL("https://github.com/subdigital/Oliphaunt"),
                        redirectURI: Self.redirectURI)
        )

        let credentials = AppCredentials(
            clientID: app.clientId,
            clientSecret: app.clientSecret,
            vapidKey: app.vapidKey
        )

        keychain.saveEncodedValue(credentials, for: appKeychainKey)

        return credentials
    }
}

enum KeychainScope {
    case app
    case user(identifier: String)

    var rawValue: String {
        switch self {
        case .app: return "app"
        case .user(identifier: let id): return "user:\(id)"
        }
    }

    func key(for baseURL: URL) -> String {
        "oliphaunt:\(rawValue):\(baseURL.absoluteString.lowercased())"
    }
}

extension Keychain {
    func saveEncodedValue<T: Encodable>(_ value: T, for key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }

        self[data: key] = data
    }

    func decodeValue<T: Decodable>(_ type: T.Type, for key: String) -> T? {
        guard let data = self[data: key] else { return nil }

        return try? JSONDecoder().decode(T.self, from: data)
    }
}

extension NSApplication: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        keyWindow ?? mainWindow ?? windows[0]
    }
}
