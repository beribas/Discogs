import Foundation
import ComposableArchitecture
import Core

struct InventoryFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        let username: String
        var listings: [Listing]
        var alert: AlertState<AlertAction>?
    }

    struct InventoryLoadingError: LocalizedError, Equatable {
      var errorDescription: String? {
        "Inventory loading failed."
      }
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case inventoryLoaded(Result<InventoryResponse, InventoryLoadingError>)
        case alert(PresentationAction<AlertAction>)
    }

    enum AlertAction: Equatable {}

    @Dependency(\.listingService) var listingService

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.alert = nil
                return .run { [username = state.username] send in
                    do {
                        let inventoryResponse = try await listingService.getInventory(username: username, page: 1)
                        await send(.inventoryLoaded(.success(inventoryResponse)))
                    } catch {
                        await send(.inventoryLoaded(.failure(InventoryLoadingError())))
                    }
                }
            case let .inventoryLoaded(.success(inventoryResponse)):
                state.listings = inventoryResponse.listings
                state.alert = nil
                return .none
            case .inventoryLoaded(.failure):
                state.alert = AlertState(title: TextState("Error occured..."))
                return .none
            case .alert:
                return .none
            }
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

actor ServiceMock: ListingServiceType {

    init(getInventoryResponse: Result<InventoryResponse, Error> = .success(.mock())) {
        self.getInventoryResponse = getInventoryResponse
    }
    private var getInventoryResponse: Result<InventoryResponse, Error>
    var receivedGetInventoryParams: [(username: String, page: Int)] = []
    func getInventory(username: String, page: Int) async throws -> InventoryResponse {
        receivedGetInventoryParams.append((username: username, page: page))
        switch getInventoryResponse {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }

    func getStats(releaseId: Int) async throws -> Stats {
        .mock()
    }
}
