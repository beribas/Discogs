import Foundation

public struct InventoryResponse: Decodable {
    public init(pagination: Pagination, listings: [Listing]) {
        self.pagination = pagination
        self.listings = listings
    }

    public let pagination: Pagination
    public let listings: [Listing]
}

extension InventoryResponse {
    public struct Pagination: Decodable {
        public init(page: Int, pages: Int) {
            self.page = page
            self.pages = pages
        }

        public let page: Int
        public let pages: Int
    }
}
