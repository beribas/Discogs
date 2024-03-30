import Foundation
import Combine

public protocol ListingServiceType: Actor {
    func getInventory(username: String, page: Int) async throws -> InventoryResponse
    func getStats(releaseId: Int) async throws -> Stats
}

public actor ListingService: ListingServiceType {
    private let network: Networking
    private let oauthtoken: String
    
    init(network: Networking) {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "OAUTHTOKEN") as? String, !token.isEmpty else {
            fatalError("No oauthtoken provided. Add the OAUTHTOKEN variable to your Keys.xcconfig. Application will crash now...")
        }
        oauthtoken = token
        self.network = network
    }
    
    public func getInventory(username: String, page: Int) async throws -> InventoryResponse {
        print("➡️ Requesting inventory for \(username) page \(page)")
        var request = URLRequest(url: URL(string: "https://api.discogs.com/users/\(username)/inventory?sort=price&sort_order=desc&page=\(page)&per_page=25")!)
        request.setValue(oauthtoken, forHTTPHeaderField: "Authorization")

        return try await network.send(request: request, decodable: InventoryResponse.self)
    }

    public func getStats(releaseId: Int) async throws -> Stats {
        var request = URLRequest(url: URL(string: "https://api.discogs.com/marketplace/stats/\(releaseId)")!)
        request.setValue(oauthtoken, forHTTPHeaderField: "Authorization")
        request.cachePolicy = .returnCacheDataElseLoad
//        request.timeoutInterval = 3
        
        return try await network.send(request: request, decodable: Stats.self)
    }
}
