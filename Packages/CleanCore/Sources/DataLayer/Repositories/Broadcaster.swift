import Foundation

/// Fans a value out to every active `AsyncStream` subscriber. Thread-safe.
final class Broadcaster<Value> {
    private var continuations: [UUID: AsyncStream<Value>.Continuation] = [:]
    private let lock = NSLock()

    func stream(initial: @escaping () async -> Value) -> AsyncStream<Value> {
        AsyncStream { continuation in
            let id = UUID()
            lock.lock()
            continuations[id] = continuation
            lock.unlock()
            continuation.onTermination = { [weak self] _ in
                self?.lock.lock()
                self?.continuations[id] = nil
                self?.lock.unlock()
            }
            Task { continuation.yield(await initial()) }
        }
    }

    func send(_ value: Value) {
        lock.lock()
        let current = Array(continuations.values)
        lock.unlock()
        current.forEach { $0.yield(value) }
    }
}
