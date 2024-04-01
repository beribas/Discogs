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
    @Bindable var store: StoreOf<InventoryFeature>
    var body: some View {
        List(store.listings) { listing in
            Text(listing.release.releaseDescription)
        }
        .navigationTitle(store.username)
        .alert($store.scope(state: \.alert, action: \.alert))
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    InventoryView(
        store: Store(initialState: InventoryFeature.State(username: "TEST", listings: []), reducer: {

        })
    )
}
