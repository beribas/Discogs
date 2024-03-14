import XCTest
import ComposableArchitecture
@testable import DiscogsTCA

@MainActor
final class InventoryFeatureTests: XCTestCase {
    func test_onAppear() async throws {
        let store = TestStore(
            initialState: InventoryFeature.State(username: "USER", listings: []),
            reducer: InventoryFeature()
        )

        await store.send(.onAppear)

        await store.receive(
            .inventoryLoaded(
                .success(
                    .init(
                        pagination: .init(page: 1, pages: 1),
                        listings: [.mock(), .mock()]
                    )
                )
            )
        ) {
            $0.listings = [.mock(), .mock()]
        }
    }
}
