import ComposableArchitecture
import Core

struct InventoryFeature: ReducerProtocol {
    struct State: Equatable {
        let username: String
        var listings: [Listing]
    }

    enum Action: Equatable {
        case onAppear
        case inventoryLoaded(TaskResult<InventoryResponse>)
    }

    @Dependency(\.listingService) var listingService

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .onAppear:
            return .task { [username = state.username] in
                await .inventoryLoaded(
                    TaskResult {
                        try await listingService.getInventory(username: username, page: 0)
                    }
                )
            }
        case let .inventoryLoaded(.success(inventoryResponse)):
            state.listings = inventoryResponse.listings
            return .none
        case let .inventoryLoaded(.failure(error)):
            return .none
        }
    }
}

private enum ListingServiceKey: DependencyKey {
    static let liveValue: any ListingServiceType = Core.Dependencies.shared.listingService
    static let previewValue: any ListingServiceType = ServiceMock()
    static let testValue: any ListingServiceType = ServiceMock()
}

extension DependencyValues {
    var listingService: any ListingServiceType {
        get { self[ListingServiceKey.self] }
        set { self[ListingServiceKey.self] = newValue }
    }
}

class ServiceMock: ListingServiceType {
    func getInventory(username: String, page: Int) async throws -> InventoryResponse {
        .init(
            pagination: .init(page: 1, pages: 1),
            listings: [.mock(), .mock()]
        )
    }

    func getStats(releaseId: Int) async throws -> Stats {
        .mock()
    }
}
