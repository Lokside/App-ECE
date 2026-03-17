import SwiftUI

struct DRemoteAssetImage: View {
    let urlString: String

    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .empty: Color.clear
            case .success(let image): image.resizable()
            case .failure: Color.clear
            @unknown default: Color.clear
            }
        }
    }
}
