import XCTest
import ComposableArchitecture
@testable import DiscogsTCA

final class SellerSelectionFeatureTests: XCTestCase {

    @MainActor
    func test_textChanged() async {
        let store = TestStore(initialState: SellerSelectionFeature.State(), reducer: { SellerSelectionFeature() })
        await store.send(.textChanged("USER")) {
            $0.username = "USER"
        }
    }

    @MainActor
    func test_setNavigationToInventory() async {
        let store = TestStore(initialState: SellerSelectionFeature.State(username: "USERNAME"), reducer: { SellerSelectionFeature() })
        await store.send(.setNavigationToInventory) {
            $0.path.append(.init(username: "USERNAME", listings: []))
        }
    }

}
