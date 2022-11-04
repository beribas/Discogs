import Foundation

struct Stats: Decodable {
    let lowestPrice: Price
    let numForSale: Int
    let blockedFromSale: Bool
    
    enum CodingKeys: String, CodingKey {
        case lowestPrice = "lowest_price"
        case numForSale = "num_for_sale"
        case blockedFromSale = "blocked_from_sale"
    }
}

extension Stats {
    static func mock() -> Self {
        .init(
            lowestPrice: .init(currency: "EUR", value: .random(in: 1.00...9.99)),
            numForSale: 0,
            blockedFromSale: false
        )
    }
}
