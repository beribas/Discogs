import Foundation

protocol RequestValidator: Actor {
    func validate(request: URLRequest) throws
}
