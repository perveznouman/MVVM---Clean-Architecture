import Foundation

/// Implements the Domain's `FavoritesRepository` by saving the favourite users as JSON in UserDefaults.
/// Because the whole user is saved, the Favourites tab works without internet.
final class FavoritesRepositoryDefaults: FavoritesRepository, @unchecked Sendable {
    private let defaults: UserDefaults
    private let key = "favorite_users"

    // The lock keeps "read, change, save" from running twice at the same moment.
    private let lock = NSLock()
    private var listeners: [UUID: AsyncStream<[User]>.Continuation] = [:]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func observeFavorites() -> AsyncStream<[User]> {
        AsyncStream { continuation in
            let id = UUID()
            lock.withLock {
                listeners[id] = continuation
                continuation.yield(load())      // send the current list straight away
            }
            continuation.onTermination = { [weak self] _ in
                self?.lock.withLock { self?.listeners[id] = nil }
            }
        }
    }

    func isFavorite(id: Int) async -> Bool {
        lock.withLock { load().contains { $0.id == id } }
    }

    func add(_ user: User) async {
        change { favorites in
            guard !favorites.contains(where: { $0.id == user.id }) else { return }
            favorites.insert(user, at: 0)       // newest first
        }
    }

    func remove(id: Int) async {
        change { favorites in favorites.removeAll { $0.id == id } }
    }

    // MARK: Private

    private func change(_ edit: (inout [User]) -> Void) {
        let (favorites, watchers) = lock.withLock { () -> ([User], [AsyncStream<[User]>.Continuation]) in
            var favorites = load()
            edit(&favorites)
            save(favorites)
            return (favorites, Array(listeners.values))
        }
        watchers.forEach { $0.yield(favorites) } // tell everyone who is watching
    }

    private func load() -> [User] {
        guard let data = defaults.data(forKey: key),
              let stored = try? JSONDecoder().decode([StoredUserDTO].self, from: data) else { return [] }
        return stored.map { $0.toDomain() }
    }

    private func save(_ favorites: [User]) {
        let data = try? JSONEncoder().encode(favorites.map(StoredUserDTO.init))
        defaults.set(data, forKey: key)
    }
}
