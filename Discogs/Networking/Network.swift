import Foundation
import Combine

protocol Networking {
    func send<T: Decodable>(request: URLRequest, decodable: T.Type) async throws -> T
}

final class Network: Networking {
    let responseListener: ResponseListener?
    let requestValidator: RequestValidator?

    init(requestValidator: RequestValidator?, responseListener: ResponseListener?) {
        self.responseListener = responseListener
        self.requestValidator = requestValidator
    }

    func send<T: Decodable>(request: URLRequest, decodable: T.Type) async throws -> T {
        if let requestValidator {
            try await requestValidator.validate(request: request)
        }
        let (data, response) = try await URLSession(configuration: .default).data(for: request)
        try await responseListener?.receiveResponse(data: data, response: response)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkingError.unknown
        }

        guard httpResponse.statusCode == 200 else {
            throw NetworkingError.badResponseCode(httpResponse.statusCode)
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkingError.decodingError(error)
        }
    }
}
