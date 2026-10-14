import Foundation
@testable import CleanBasic

func makeUser(_ id: Int, _ name: String = "User") -> User {
    User(id: id, name: "\(name) \(id)", username: "u\(id)", email: "u\(id)@example.com",
         phone: "123", website: "example.org",
         address: Address(street: "Kulas Light", suite: "Apt. 556", city: "Gwenborough", zipcode: "92998"),
         avatarURL: URL(string: "https://example.com/\(id).png"))
}

struct TestError: LocalizedError {
    var errorDescription: String? { "boom" }
}

/// Fake repository: lets us test without the network.
struct FakeUserRepository: UserRepository {
    var result: Result<[User], Error> = .success([])
    func fetchUsers() async throws -> [User] { try result.get() }
}

/// Fake favourites storage kept in memory. Replays its list once, like the real one does on subscribing.
final class FakeFavoritesRepository: FavoritesRepository {
    private(set) var users: [User] = []

    func observeFavorites() -> AsyncStream<[User]> {
        let current = users
        return AsyncStream { continuation in
            continuation.yield(current)
            continuation.finish()
        }
    }

    func isFavorite(id: Int) async -> Bool { users.contains { $0.id == id } }
    func add(_ user: User) async { users.insert(user, at: 0) }
    func remove(id: Int) async { users.removeAll { $0.id == id } }
}

// Fake use cases for the view model tests.
final class FakeGetUsers: GetUsersUseCase {
    var result: Result<[User], Error> = .success([])
    func execute() async throws -> [User] { try result.get() }
}

final class FakeObserveFavorites: ObserveFavoritesUseCase {
    var snapshots: [[User]] = []
    func execute() -> AsyncStream<[User]> {
        let snapshots = snapshots
        return AsyncStream { continuation in
            snapshots.forEach { continuation.yield($0) }
            continuation.finish()
        }
    }
}

final class FakeToggleFavorite: ToggleFavoriteUseCase {
    private(set) var toggled: [User] = []
    func execute(_ user: User) async { toggled.append(user) }
}
