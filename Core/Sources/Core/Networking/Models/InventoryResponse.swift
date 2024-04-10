import Foundation

public struct InventoryResponse: Decodable, Equatable, Sendable {
    public init(pagination: Pagination, listings: [Listing]) {
        self.pagination = pagination
        self.listings = listings
    }

    public let pagination: Pagination
    public let listings: [Listing]
}

extension InventoryResponse {
    public struct Pagination: Decodable, Equatable, Sendable {
        public init(page: Int, pages: Int) {
            self.page = page
            self.pages = pages
        }

        public let page: Int
        public let pages: Int
    }
}

// MARK: - Mocks

public extension InventoryResponse {
    static func mock() -> Self {
        .init(
            pagination: .init(page: 1, pages: 1),
            listings: [.mock(), .mock()]
        )
    }
}
