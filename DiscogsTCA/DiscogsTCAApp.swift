import SwiftUI
import ComposableArchitecture

@main
struct DiscogsTCAApp: App {
    var body: some Scene {
        WindowGroup {
            SellerSelectionView(
                store: Store(initialState: .init(username: "")) {
                    SellerSelectionFeature()
                        ._printChanges()
                }
            )
        }
    }
}
