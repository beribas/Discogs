import SwiftUI
import Combine

extension Listing: Identifiable, Hashable {
    static func == (lhs: Listing, rhs: Listing) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ListingsView: View {
    @StateObject var viewModel: ListingsViewModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<viewModel.listingItems.count, id: \.self) { index in
                    let listing = viewModel.listingItems[index]
                    NavigationLink(value: listing) {
                        ListingItemView(viewModel: listing)
                            .onAppear {
                                viewModel.itemAppeared(at: index)
                            }
                    }
                }
                if viewModel.fetchingAdditionalItems {
                    ProgressView().foregroundColor(.black)
                }
            }
            .refreshable {
                await viewModel.fetch()
            }
            .searchable(text: $viewModel.searchTerm)
            .autocorrectionDisabled()
            .navigationTitle(viewModel.username)
            .toolbar {
                if let secondsLeft = viewModel.rateLimitSecondsLeft {
                    Text(String(secondsLeft)).foregroundColor(.red)
                }
            }
            .toolbar {
                Button("Sort") {
                    withAnimation {
                        viewModel.sort()
                    }
                }
            }
            .navigationDestination(for: Listing.self) { listing in
                ReleaseView(release: listing.release)
            }
            .overlay {
                if viewModel.initialFetch {
                    ProgressView {
                        Text("Loading... ")
                    }
                }
            }
            .alert(
                isPresented: $viewModel.showError,
                error: viewModel.errorMessage) { _ in

                } message: { error in
                    Text(error.recoverySuggestion ?? "")
                }
        }
        .task {
            await viewModel.fetch()
        }
    }
}

struct ListingsView_Previews: PreviewProvider {
    static var previews: some View {
        ListingsView(viewModel: .init(username: "Skotty25", service: ServiceMock()))
            .environmentObject(ImageLoader())
            .previewDisplayName("With some values")
        ListingsView(viewModel: viewModelWithRateLimitMock())
            .environmentObject(ImageLoader())
            .previewDisplayName("Rate limit active")
    }
}

extension ListingsView_Previews {
    class ServiceMock: ListingServiceType {
        func getInventory(username: String, page: Int) async throws -> InventoryResponse {
            .init(
                pagination: .init(page: 1, pages: 1),
                listings: [.mock(), .mock()]
            )
        }

        func getStats(releaseId: Int) async throws -> Stats {
            .mock()
        }
    }

    actor RateLimitHandlerMock: RateLimitHandlerType {
        var rateLimitTimerSecondsLeft: AnyPublisher<Int?, Never> {
            Just(59).eraseToAnyPublisher()
        }
    }

    static func viewModelWithRateLimitMock() -> ListingsViewModel {
        let handlerMock = RateLimitHandlerMock()
        return .init(username: "Skotty25", service: ServiceMock(), rateLimitHandler: handlerMock)
    }
}
