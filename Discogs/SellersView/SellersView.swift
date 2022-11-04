import SwiftUI

struct SellersView: View {
    @State private var sellerName = ""
    @State private var submitted: Bool = false
    var body: some View {
        NavigationStack {
            VStack {
                TextField("Seller name", text: $sellerName)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onSubmit {
                        submitted = true
                    }
            }
            .padding()
            .navigationTitle("Seller")
            .navigationDestination(isPresented: $submitted) {
                ListingsView(viewModel: .init(username: sellerName))
                    .environmentObject(ImageLoader())
            }
        }
    }
}

struct SellersView_Previews: PreviewProvider {
    static var previews: some View {
        SellersView()
    }
}
