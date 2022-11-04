import Foundation

struct InventoryResponse: Decodable {
    let pagination: Pagination
    let listings: [Listing]
}

extension InventoryResponse {
    struct Pagination: Decodable {
        let page: Int
        let pages: Int
    }
}
