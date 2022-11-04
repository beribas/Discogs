import Foundation

// MARK: - Welcome
struct Listing: Decodable {
    let price: Price
    let sleeveCondition: String
    let id: Int
    let condition: String
    let shipsFrom: String
    let shippingPrice: Price
    let release: Release

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
struct Release: Codable {
    let catalogNumber: String
    let resourceURL: String
    let year, id: Int
    let releaseDescription: String
    let thumbnail: String

    enum CodingKeys: String, CodingKey {
        case catalogNumber = "catalog_number"
        case resourceURL = "resource_url"
        case year, id
        case releaseDescription = "description"
        case thumbnail
    }
}

// MARK: - Mocks

extension Release {
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

extension Listing {
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
