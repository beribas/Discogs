import Foundation
import SwiftUI
import Combine
import Core

class ListingsViewModel: ObservableObject {

    struct Error: LocalizedError {
        var errorDescription: String? {
            "Something went wrong"
        }
        
        var recoverySuggestion: String? {
            "Try again later"
        }
    }

    private let service: ListingServiceType
    private var pages = -1
    private var currentPage = 0
    private var timerSubscription: AnyCancellable?

    let username: String
    
    init(
        username: String,
        service: ListingServiceType = Dependencies.shared.listingService,
        rateLimitHandler: RateLimitHandlerType = Dependencies.shared.rateLimitHandler
    ) {
        self.username = username
        self.service = service

        Task {
            timerSubscription = await rateLimitHandler.rateLimitTimerSecondsLeft
                .sink(receiveValue: { [weak self] secondsLeft in
                    self?.rateLimitSecondsLeft = secondsLeft
                })
        }

        Publishers.CombineLatest($originalListingItems, $searchTerm)
            .map { originalListings, searchTerm in
                originalListings.filter { listing in
                    searchTerm.isEmpty ? true : listing.title.contains(searchTerm)
                }
            }
            .assign(to: &$listingItems)
    }

    @Published var listingItems: [ListingItemViewModel] = []
    @Published var originalListingItems: [ListingItemViewModel] = []

    @Published var searchTerm: String = ""
    @Published private(set) var initialFetch = false
    @Published private(set) var fetchingAdditionalItems = false
    @Published private(set) var errorMessage: Error?
    @Published var showError: Bool = false
    @Published private(set) var rateLimitSecondsLeft: Int?
    
    @MainActor func fetch() async {
        defer {
            initialFetch = false
            fetchingAdditionalItems = false
        }
        let pageToFetch: Int
        if pages == -1 {
            pageToFetch = 1
            initialFetch = true
        } else if currentPage < pages {
            fetchingAdditionalItems = true
            pageToFetch = currentPage + 1
        } else {
            return
        }
        await _fetch(page: pageToFetch)
    }

    @MainActor func itemAppeared(at index: Int) {
        loadStats(at: index)
        if index > originalListingItems.count - 5 {
            Task {
                await fetch()
            }
        }
    }

    @MainActor func sort() {
        originalListingItems.sort { $0.priceGrading.rawValue < $1.priceGrading.rawValue }
    }

}

private extension ListingsViewModel {
    @MainActor func _fetch(page: Int) async {
        do {
            let inventoryResponse = try await service.getInventory(username: username, page: page)
            let newItems = inventoryResponse.listings
                .map { ListingItemViewModel(listing: $0, service: service) }
            originalListingItems.append(contentsOf: newItems)
            pages = inventoryResponse.pagination.pages
            currentPage = inventoryResponse.pagination.page
        }
        catch {
            handleError(error)
        }
    }

    private func handleError(_ error: Swift.Error) {
        guard !(error is RateLimitReachedError) else { return }
        errorMessage = Error()
        showError = true
    }

    @MainActor private func loadStats(at index: Int) {
        if case .finished = listingItems[index].statsState {
            return
        }
        Task {
            do {
                listingItems[index].statsState = .loading
                let stats = try await service.getStats(releaseId: listingItems[index].listing.release.id)
                listingItems[index].statsState = .finished(lowestPrice: stats.lowestPrice)
            } catch is RateLimitReachedError {
                listingItems[index].statsState = .paused
            } catch {
                listingItems[index].statsState = .failed
            }
        }
    }
}
