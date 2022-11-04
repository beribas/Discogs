import SwiftUI

struct SellersView: View {
    @State private var sellerName = ""
    @State private var submitted: Bool = false
    @AppStorage("previousSearches") var previousSearches: [String] = []

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Seller name", text: $sellerName)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onSubmit {
                        submitted = true
                    }
                Text("Previous searches:")
                ForEach(previousSearches, id: \.self) { search in
                    NavigationLink(value: search) {
                        Text(search)
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Seller")
            .navigationDestination(isPresented: $submitted) {
                ListingsView(viewModel: .init(username: sellerName))
                    .environmentObject(ImageLoader())
                    .onAppear {
                        let lowercased = sellerName.lowercased()
                        if !previousSearches.contains(lowercased) {
                            previousSearches.append(lowercased)
                        }
                    }
            }
            .navigationDestination(for: String.self) { search in
                ListingsView(viewModel: .init(username: search))
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

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
