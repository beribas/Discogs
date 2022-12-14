import ComposableArchitecture

struct SellerSelectionFeature: ReducerProtocol {
    struct State: Equatable {
        var username: String = ""
        var navigationToInventoryActive = false
        var inventoryState: InventoryFeature.State?
    }

    enum Action {
        case textChanged(String)
        case setNavigationToInventory(Bool)
        case inventory(InventoryFeature.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .textChanged(let string):
                state.username = string
                return .none
            case .setNavigationToInventory(true):
                state.navigationToInventoryActive = true
                state.inventoryState = .init(username: state.username, listings: [])
                return .none
            case .setNavigationToInventory(false):
                state.navigationToInventoryActive = false
                state.inventoryState = nil
                return .none
            case .inventory:
                return .none
            }
        }
        .ifLet(\.inventoryState, action: /SellerSelectionFeature.Action.inventory) {
            InventoryFeature()
        }
    }
}
