import ComposableArchitecture

struct SellerSelectionFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var username: String = ""
        var path = StackState<InventoryFeature.State>()
    }

    @CasePathable
    enum Action {
        case textChanged(String)
        case setNavigationToInventory
        case path(StackAction<InventoryFeature.State, InventoryFeature.Action>)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .textChanged(let string):
                state.username = string
            case .setNavigationToInventory:
                state.path.append(.init(username: state.username, listings: []))
            case .path:
                break
            }
            return .none
        }
        .forEach(\.path, action: \.path) {
            InventoryFeature()
        }
    }
}
