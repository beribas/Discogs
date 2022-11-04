import Foundation
import Combine

struct RateLimitReachedError: Error {
    let secondsLeft: Int
}

protocol RateLimitHandlerType: Actor {
    var rateLimitTimerSecondsLeft: AnyPublisher<Int?, Never> { get }
}

actor RateLimitHandler: RateLimitHandlerType, ResponseListener, RequestValidator {
    var rateLimitTimerSecondsLeft: AnyPublisher<Int?, Never> { timerSubject.eraseToAnyPublisher() }
    private let timerSubject = PassthroughSubject<Int?, Never>()
    private let timer = Timer.publish(every: 1, on: .main, in: .default)
    private var lastLimitReachedDate: Date?
    private var cancellable: AnyCancellable?
    private static var rateLimit = 60

    func receiveResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            return
        }

        [
            "X-Discogs-Ratelimit-Used",
            "X-Discogs-Ratelimit-Remaining"
        ].forEach { headerName in
            print("\(headerName): \(httpResponse.value(forHTTPHeaderField: headerName) ?? "")")
        }

        if let rateLimit = httpResponse.value(forHTTPHeaderField: "X-Discogs-Ratelimit"),
           let rateLimitInt = Int(rateLimit) {
            Self.rateLimit = rateLimitInt
        }

        if let rateLimitRemaining = httpResponse.value(forHTTPHeaderField: "X-Discogs-Ratelimit-Remaining"),
           let rateLimitInt = Int(rateLimitRemaining),
           rateLimitInt == 0 {
            lastLimitReachedDate = Date()
            startTimer()
        }
    }

    func validate(request: URLRequest) throws {
        guard let lastLimitReachedDate else { return }
        let secondsLeft = 60 - Date().timeIntervalSince(lastLimitReachedDate)
        if secondsLeft > 0 {
            throw RateLimitReachedError(secondsLeft: Int(secondsLeft))
        }
    }

    private func startTimer() {
        if cancellable != nil {
            return
        }
        cancellable?.cancel()
        cancellable = timer
            .autoconnect()
            .scan(Self.rateLimit) { counter, _ in
                let nextValue = counter - 1
                if nextValue <= 0 {
                    self.timerSubject.send(nil)
                    self.stopTimer()
                }
                return nextValue
            }
            .replaceError(with: 0)
            .sink { value in
                self.timerSubject.send(value)
            }
    }

    private func stopTimer() {
        cancellable?.cancel()
    }
}
