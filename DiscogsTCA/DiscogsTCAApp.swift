import SwiftUI
import ComposableArchitecture

@main
struct DiscogsTCAApp: App {
    var body: some Scene {
        WindowGroup {
            InventoryView(
                store: Store(
                    initialState: .init(username: "", listings: []),
                    reducer: InventoryFeature()
                )
            )
        }
    }
}
