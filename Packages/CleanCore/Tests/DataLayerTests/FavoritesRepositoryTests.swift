import XCTest
import Domain
@testable import DataLayer

/// Runs the real Core Data code against an in-memory store.
final class FavoritesRepositoryTests: XCTestCase {
    private var repository: FavoritesRepositoryImpl!

    override func setUp() {
        super.setUp()
        repository = FavoritesRepositoryImpl(container: PersistenceController(inMemory: true).container)
    }

    private func user(_ id: Int, coordinate: Coordinate? = Coordinate(latitude: 1.5, longitude: -2.5)) -> User {
        User(id: id, name: "User \(id)", username: "u\(id)", email: "u\(id)@x.com", phone: "1", website: "w.org",
             address: Address(street: "S", suite: "Su", city: "C", zipcode: "Z", coordinate: coordinate),
             company: Company(name: "Co", catchPhrase: "P", bs: "B"),
             avatarURL: URL(string: "https://example.com/\(id).png"))
    }

    func test_addThenRead_roundTripsAllFields() async throws {
        try await repository.add(user(1))

        var iterator = repository.observeFavorites().makeAsyncIterator()
        let favorites = await iterator.next()

        XCTAssertEqual(favorites, [user(1)])
        let isFavorite = await repository.isFavorite(userID: 1)
        XCTAssertTrue(isFavorite)
    }

    func test_userWithoutCoordinate_roundTripsAsNil() async throws {
        try await repository.add(user(1, coordinate: nil))
        var iterator = repository.observeFavorites().makeAsyncIterator()
        let favorites = await iterator.next()
        XCTAssertNil(favorites?.first?.address.coordinate)
    }

    func test_addingTwice_keepsOneRecord() async throws {
        try await repository.add(user(1))
        try await repository.add(user(1))
        var iterator = repository.observeFavorites().makeAsyncIterator()
        let favorites = await iterator.next()
        XCTAssertEqual(favorites?.count, 1)
    }

    func test_remove() async throws {
        try await repository.add(user(1))
        try await repository.remove(userID: 1)
        let isFavorite = await repository.isFavorite(userID: 1)
        XCTAssertFalse(isFavorite)
    }

    func test_newestFirst() async throws {
        try await repository.add(user(1))
        try await repository.add(user(2))
        var iterator = repository.observeFavorites().makeAsyncIterator()
        let favorites = await iterator.next()
        XCTAssertEqual(favorites?.map(\.id), [2, 1])
    }

    func test_observersAreToldAboutLaterChanges() async throws {
        var iterator = repository.observeFavorites().makeAsyncIterator()
        let initial = await iterator.next()
        XCTAssertEqual(initial, [])

        try await repository.add(user(7))
        let afterAdd = await iterator.next()
        XCTAssertEqual(afterAdd?.map(\.id), [7])

        try await repository.remove(userID: 7)
        let afterRemove = await iterator.next()
        XCTAssertEqual(afterRemove, [])
    }

    func test_avatarAndWeatherAreSavedPerFavourite() async throws {
        try await repository.add(user(1))
        await repository.saveAvatarData(Data([1, 2]), for: 1)
        let weather = Weather(
            current: .init(temperature: 1, apparentTemperature: 1, humidity: 1, windSpeed: 1, condition: .clear),
            daily: [])
        await repository.saveWeather(weather, for: 1)

        let avatar = await repository.avatarData(for: 1)
        let cached = await repository.cachedWeather(for: 1)
        XCTAssertEqual(avatar, Data([1, 2]))
        XCTAssertEqual(cached?.weather, weather)
    }

    func test_savingExtrasForANonFavourite_isIgnored() async {
        await repository.saveAvatarData(Data([1]), for: 99)
        let avatar = await repository.avatarData(for: 99)
        XCTAssertNil(avatar)
    }
}
