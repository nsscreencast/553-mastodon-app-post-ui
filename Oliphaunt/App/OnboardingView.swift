import SwiftUI
import Manfred
import KeychainAccess

struct AppCredentials: Codable {
    let clientID: String
    let clientSecret: String
    let vapidKey: String
}

struct OnboardingView: View {
    @ObservedObject var accountController: AccountController
    @State var selectedServer: String? = nil

    var body: some View {
        InstanceSelectionView(selectedServer: $selectedServer)
            .onChange(of: selectedServer) { newValue in
                if let selectedServer = newValue {
                    accountController.selectServer(selectedServer)
                }
            }
    }
}
