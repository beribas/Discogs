import ComposableArchitecture

struct InventoryFeature: ReducerProtocol {
    struct State: Equatable {}
    enum Action {
        case onAppear
        case inventoryLoaded(TaskResult<InventoryResponse>)
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        return .none
    }
}
