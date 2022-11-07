import Foundation

public class Dependencies {
    public static let shared: Dependencies = .init()
    private let network: Networking
    public let listingService: ListingServiceType
    public let rateLimitHandler = RateLimitHandler()

    init() {
        network = Network(requestValidator: rateLimitHandler, responseListener: rateLimitHandler)
        listingService = ListingService(network: network)
    }
}

