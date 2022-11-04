import Foundation

class Dependencies {
    static let shared: Dependencies = .init()
    private let network: Networking
    let listingService: ListingServiceType
    let rateLimitHandler = RateLimitHandler()

    init() {
        network = Network(requestValidator: rateLimitHandler, responseListener: rateLimitHandler)
        listingService = ListingService(network: network)
    }
}
