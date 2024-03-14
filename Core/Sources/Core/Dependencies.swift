import Foundation

public class Dependencies {
    public static let shared: Dependencies = .init()
    private let network: Networking
    public let listingService: ListingServiceType
    public let rateLimitHandler = RateLimitNotifier()

    init() {
        network = Network(requestValidator: rateLimitHandler, responseListener: rateLimitHandler)
        listingService = ListingService(network: network)
    }
}

