import Foundation

protocol ResponseListener: Actor {
    func receiveResponse(data: Data, response: URLResponse) throws
}
