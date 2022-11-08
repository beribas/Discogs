import Foundation

// MARK: - Price
public struct Price: Codable, Equatable {
    public let currency: String
    public let value: Double
}

public extension Price {
    var formatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }
}
