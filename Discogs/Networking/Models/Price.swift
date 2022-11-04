import Foundation

// MARK: - Price
struct Price: Codable {
    let currency: String
    let value: Double
}

extension Price {
    var formatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}
