import Foundation
import ComposableArchitecture

struct SellerSelectionFeature: Reducer {
    @Dependency(\.searchHistory) var searchHistory

    @ObservableState
    struct State: Equatable {
        init(username: String = "",
             path: StackState<InventoryFeature.State> = StackState<InventoryFeature.State>()
        ) {
            self.username = username
            self.path = path
            @Dependency(\.searchHistory) var searchHistory
            self.previousSearches = searchHistory
        }

        var username: String = ""
        var path = StackState<InventoryFeature.State>()
        var previousSearches: [String]
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
                if let index = state.previousSearches.firstIndex(of: state.username) {
                    state.previousSearches.move(fromOffsets: IndexSet(integer: index), toOffset: 0)
                } else {
                    state.previousSearches.insert(state.username, at: 0)
                }
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

private enum SearchHistoryKey: DependencyKey {
  static var liveValue = [String]()
}

extension DependencyValues {
  var searchHistory: [String] {
    get { self[SearchHistoryKey.self] }
    set { self[SearchHistoryKey.self] = newValue }
  }
}
