import XCTest
import ComposableArchitecture
@testable import DiscogsTCA

final class InventoryFeatureTests: XCTestCase {
    struct FakeError: Error {}
    @MainActor
    func test_onAppear_inventoryLoadSucceeded() async throws {
        let service = ServiceMock(
            getInventoryResponse: .success(.init(
                pagination: .init(page: 1, pages: 1),
                listings: [.mock(), .mock()]
            ))
        )
        let store = TestStore(
            initialState: InventoryFeature.State(username: "USER", listings: []),
            reducer: { InventoryFeature() }
        ) {
            $0.listingService = service
        }

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

        let receivedParams = await service.receivedGetInventoryParams
        let firstTuple = try XCTUnwrap(receivedParams.first)
        XCTAssertEqual(receivedParams.count, 1)
        XCTAssertEqual(firstTuple.username, "USER")
        XCTAssertEqual(firstTuple.page, 1)
    }

    @MainActor
    func test_onAppear_inventoryLoadFailed() async throws {
        let service = ServiceMock(
            getInventoryResponse: .failure(FakeError())
        )
        let store = TestStore(
            initialState: InventoryFeature.State(username: "USER", listings: []),
            reducer: { InventoryFeature() }
        ) {
            $0.listingService = service
        }

        await store.send(.onAppear)

        await store.receive(
            .inventoryLoaded(.failure(InventoryFeature.InventoryLoadingError()))
        ) {
            $0.alert = AlertState(title: TextState("Error occured..."))
        }

        let receivedParams = await service.receivedGetInventoryParams
        let firstTuple = try XCTUnwrap(receivedParams.first)
        XCTAssertEqual(receivedParams.count, 1)
        XCTAssertEqual(firstTuple.username, "USER")
        XCTAssertEqual(firstTuple.page, 1)
    }
}
