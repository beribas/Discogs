import Foundation

public struct Listing: Decodable, Equatable {
    public let price: Price
    public let sleeveCondition: String
    public let id: Int
    public let condition: String
    public let shipsFrom: String
    public let shippingPrice: Price
    public let release: Release

    enum CodingKeys: String, CodingKey {
        case price
        case sleeveCondition = "sleeve_condition"
        case id, condition
        case shipsFrom = "ships_from"
        case shippingPrice = "shipping_price"
        case release
    }
}

// MARK: - Release
public struct Release: Codable, Equatable {
    public let catalogNumber: String
    public let resourceURL: String
    public let year, id: Int
    public let releaseDescription: String
    public let thumbnail: String

    enum CodingKeys: String, CodingKey {
        case catalogNumber = "catalog_number"
        case resourceURL = "resource_url"
        case year, id
        case releaseDescription = "description"
        case thumbnail
    }
}

// MARK: - Mocks

public extension Release {
    static func mock() -> Self {
        .init(
            catalogNumber: "NR",
            resourceURL: "URL",
            year: 2000,
            id: 2594984,
            releaseDescription: "MOCK RELEASE",
            thumbnail: "https://i.discogs.com/TcnRdsCvtbSB1-6jiXQZrK1GlsyntWc93KvM730FY8U/rs:fit/g:sm/q:40/h:150/w:150/czM6Ly9kaXNjb2dz/LWRhdGFiYXNlLWlt/YWdlcy9SLTEwMTU3/NzEtMTE4NDM1ODg4/Ni5qcGVn.jpeg"
        )
    }
}

public extension Listing {
    static func mock() -> Self {
        .init(
            price: .init(currency: "EUR", value: 9.99),
            sleeveCondition: "Mint",
            id: 0,
            condition: "Very Good +",
            shipsFrom: "Germany",
            shippingPrice: .init(currency: "EUR", value: 4.99),
            release: .mock()
        )
    }
}
