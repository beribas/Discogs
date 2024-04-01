import SwiftUI
import ComposableArchitecture

struct SellerSelectionView: View {
    @Bindable var store: StoreOf<SellerSelectionFeature>
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack(alignment: .leading, spacing: 16) {
                TextField(
                    "Seller name",
                    text: $store.username.sending(\.textChanged)
                )
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .onSubmit {
                    store.send(.setNavigationToInventory)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Seller")
        } destination: { store in
            InventoryView(store: store)
        }
    }
}

#Preview {
    SellerSelectionView(
        store: Store(initialState: .init()) {
            SellerSelectionFeature()
        }
    )
}
