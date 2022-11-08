import SwiftUI
import ComposableArchitecture
import Core

extension Listing: Identifiable, Hashable {
    public static func == (lhs: Listing, rhs: Listing) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct InventoryView: View {
    let store: StoreOf<InventoryFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List(viewStore.listings) { listing in
                Text(listing.release.releaseDescription)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView(
            store: Store(
                initialState: InventoryFeature.State(username: "TEST", listings: []),
                reducer: InventoryFeature()
            )
        )
    }
}
