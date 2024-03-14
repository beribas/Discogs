import XCTest
import ComposableArchitecture
@testable import DiscogsTCA

@MainActor
final class SellerSelectionFeatureTests: XCTestCase {

    func test_textChanged() async {
      let store = TestStore(
        initialState: SellerSelectionFeature.State(),
        reducer: SellerSelectionFeature()
      )

        await store.send(.textChanged("BLAAA")) {
            $0.username = "BLAAA"
        }
    }

}
