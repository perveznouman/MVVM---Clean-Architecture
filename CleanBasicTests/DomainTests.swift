import XCTest
@testable import CleanBasic

/// Domain: use cases, tested with fake repositories. No network, no storage.
final class DomainTests: XCTestCase {
    func test_getUsers_returnsUsersSortedByName() async throws {
        let repository = FakeUserRepository(result: .success([makeUser(1, "Zed"), makeUser(2, "Amy")]))
        let users = try await DefaultGetUsersUseCase(repository: repository).execute()
        XCTAssertEqual(users.map(\.name), ["Amy 2", "Zed 1"])
    }

    func test_toggle_addsANonFavourite() async {
        let repository = FakeFavoritesRepository()
        await DefaultToggleFavoriteUseCase(repository: repository).execute(makeUser(1))
        XCTAssertEqual(repository.users.map(\.id), [1])
    }

    func test_toggle_removesAFavourite() async {
        let repository = FakeFavoritesRepository()
        await repository.add(makeUser(1))
        await DefaultToggleFavoriteUseCase(repository: repository).execute(makeUser(1))
        XCTAssertTrue(repository.users.isEmpty)
    }

    func test_observe_passesTheRepositoryStream() async {
        let repository = FakeFavoritesRepository()
        await repository.add(makeUser(7))
        var received: [[User]] = []
        for await favorites in DefaultObserveFavoritesUseCase(repository: repository).execute() {
            received.append(favorites)
        }
        XCTAssertEqual(received.first?.map(\.id), [7])
    }
}
