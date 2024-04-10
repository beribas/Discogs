import SwiftUI
import ComposableArchitecture

@main
struct DiscogsTCAApp: App {
    var body: some Scene {
        WindowGroup {
            SellerSelectionView(
                store: Store(initialState: .init()) {
                    SellerSelectionFeature()
                        ._printChanges()
                }
            )
        }
    }
}
