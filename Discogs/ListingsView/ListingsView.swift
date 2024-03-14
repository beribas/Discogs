import SwiftUI
import Combine
import Core

extension Listing: Identifiable, Hashable {
    public static func == (lhs: Listing, rhs: Listing) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ListingsView: View {
    private let username: String
    private let service: ListingServiceType
    private let rateLimitHandler: RateLimitNotifierType
    @StateObject var viewModel: ListingsViewModel

    init(
        username: String,
        service: ListingServiceType = Dependencies.shared.listingService,
        rateLimitHandler: RateLimitNotifierType = Dependencies.shared.rateLimitHandler
    ){
        self.username = username
        self.service = service
        self.rateLimitHandler = rateLimitHandler
        _viewModel = .init(wrappedValue: .init(username: username, service: service, rateLimitHandler: rateLimitHandler))
    }

    var body: some View {
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
                ProgressView().foregroundColor(.secondary).id(UUID())
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
        .navigationDestination(for: ListingItemViewModel.self) { model in
            ReleaseView(release: model.listing.release)
        }
        .overlay {
            if viewModel.initialFetch {
                ProgressView {
                    Text("Loading... ")
                }
            }
        }
        .task(id: "once") {
            await viewModel.fetch()
        }
        .alert(
            isPresented: $viewModel.showError,
            error: viewModel.errorMessage
        ) { _ in

        } message: { error in
            Text(error.recoverySuggestion ?? "")
        }

    }
}

struct ListingsView_Previews: PreviewProvider {
    static var previews: some View {
        ListingsView(username: "Skotty25", service: ServiceMock())
            .environmentObject(ImageLoader())
            .previewDisplayName("With some values")
        ListingsView(username: "Skotty25", service: ServiceMock(), rateLimitHandler: RateLimitHandlerMock())
            .environmentObject(ImageLoader())
            .previewDisplayName("Rate limit active")
    }
}

extension ListingsView_Previews {
    actor ServiceMock: ListingServiceType {
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

    actor RateLimitHandlerMock: RateLimitNotifierType {
        nonisolated var rateLimitTimerSecondsLeft: AnyPublisher<Int?, Never> {
            Just(59).eraseToAnyPublisher()
        }
    }
}
