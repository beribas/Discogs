import SwiftUI
import ComposableArchitecture

struct SellerSelectionView: View {
    var store: StoreOf<SellerSelectionFeature>
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                VStack(alignment: .leading, spacing: 16) {
                    TextField("Seller name", text: viewStore.binding(get: \.username, send: SellerSelectionFeature.Action.textChanged))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .onSubmit {
                            viewStore.send(.setNavigationToInventory(true))
                        }
                    Spacer()
                }
                .navigationDestination(
                    isPresented: viewStore.binding(
                        get: \.navigationToInventoryActive,
                        send: SellerSelectionFeature.Action.setNavigationToInventory
                    ),
                    destination: {
                        IfLetStore(
                            self.store.scope(
                                state: \.inventoryState,
                                action: SellerSelectionFeature.Action.inventory
                            )
                        ) {
                            InventoryView(store: $0)
                        }
                    }
                )
                .padding()
                .navigationTitle("Seller")
            }
        }
    }
}

struct SellerSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        SellerSelectionView(store: Store(initialState: .init(), reducer: SellerSelectionFeature()))
    }
}
