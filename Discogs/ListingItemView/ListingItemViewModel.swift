import SwiftUI

class ListingItemViewModel: ObservableObject, Identifiable, Hashable {
    enum StatsState {
        case loading
        case finished(lowestPrice: Price)
        case paused
        case failed
    }

    static func == (lhs: ListingItemViewModel, rhs: ListingItemViewModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    enum PriceGrading: Int {
        case low
        case middle
        case high
        case unknown
    }
    @Published var stats: Stats?
    @Published var statsState: StatsState = .loading

    private let service: ListingServiceType
    let listing: Listing

    var id: Int {
        listing.id
    }
    var title: String {
        listing.release.releaseDescription
    }
    var price: String {
        listing.price.formatted
    }

    var priceGrading: PriceGrading {
        let price = listing.price.value
        if case let .finished(lowestPrice) = statsState {
            if lowestPrice.value == price {
                return .low
            } else if price / lowestPrice.value < 1.2 {
                return .middle
            } else {
                return .high
            }
        } else {
            return .unknown
        }
    }
    var thumbnailURL: URL? {
        URL(string: listing.release.thumbnail)
    }

    init(listing: Listing, service: ListingServiceType) {
        self.listing = listing
        self.service = service
    }
}
