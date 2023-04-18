import SwiftUI

fileprivate var popularServers: [String] = [
    "mastodon.social",
    "mastodon.xyz",
    "hachyderm.io"
]

struct InstanceSelectionView: View {
    @Binding var selectedServer: String?

    @State private var serverTextContent: String = ""
    @State private var selectedListItem: String?

    var body: some View {
        VStack {
            HStack(spacing: 20) {
                TextField("server", text: $serverTextContent)
                Button {
                    guard !serverTextContent.isEmpty else { return }
                    
                    withAnimation(.oliphaunt) {
                        selectedServer = serverTextContent
                    }
                } label: {
                    Image(systemName: "arrow.right")
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()

            List(selection: $selectedListItem) {
                ForEach(popularServers, id: \.self) { server in
                    Text(server)
                        .tag(server)
                }
            }
        }
        .onChange(of: selectedListItem) { newValue in
            guard let newValue else { return }
            serverTextContent = newValue
        }
        .onChange(of: serverTextContent) { newValue in
            if newValue != selectedListItem {
                selectedListItem = nil
            }
        }
    }
}

#if DEBUG
struct InstanceSelectionView_Previews: PreviewProvider, View {
    @State var server: String?
    var body: some View {
        VStack {
            InstanceSelectionView(
                selectedServer: $server
            )
            Divider()
            Text(server ?? "")
                .foregroundColor(.yellow)
        }
    }

    static var previews: some View {
        InstanceSelectionView_Previews()
            .previewLayout(.fixed(width: 400, height: 300))
    }
}
#endif


extension Animation {
    static var oliphaunt: Animation {
        if NSEvent.modifierFlags.contains(.shift) {
            return .default.speed(0.25)
        } else {
            return .default
        }
    }
}
