import Foundation

public enum NetworkingError: Error {
    case badResponseCode(Int)
    case decodingError(Error)
    case unknown
}
