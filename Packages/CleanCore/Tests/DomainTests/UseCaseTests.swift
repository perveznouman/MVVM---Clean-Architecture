import XCTest
@testable import Domain

/// Use-case tests need no UI, no network and no database: only fakes of the repository protocols.
final class ToggleFavoriteUseCaseTests: XCTestCase {
    func test_favouritingAddsUserAndSavesAvatar() async throws {
        let favorites = FakeFavoritesRepository()
        let images = FakeImageRepository()
        images.data = Data([1, 2, 3])
        let useCase = DefaultToggleFavoriteUseCase(favorites: favorites, images: images)

        let isFavorite = try await useCase.execute(.fixture(id: 4))

        XCTAssertTrue(isFavorite)
        XCTAssertEqual(favorites.users.map(\.id), [4])
        XCTAssertEqual(favorites.avatars[4], Data([1, 2, 3]))
    }

    func test_favouritingStillSucceedsWhenAvatarDownloadFails() async throws {
        let favorites = FakeFavoritesRepository()
        let useCase = DefaultToggleFavoriteUseCase(favorites: favorites, images: FakeImageRepository())

        let isFavorite = try await useCase.execute(.fixture())

        XCTAssertTrue(isFavorite)
        XCTAssertNil(favorites.avatars[1])
    }

    func test_togglingAFavouriteRemovesIt() async throws {
        let favorites = FakeFavoritesRepository()
        try await favorites.add(.fixture())
        let useCase = DefaultToggleFavoriteUseCase(favorites: favorites, images: FakeImageRepository())

        let isFavorite = try await useCase.execute(.fixture())

        XCTAssertFalse(isFavorite)
        XCTAssertTrue(favorites.users.isEmpty)
    }
}

final class LoadAvatarUseCaseTests: XCTestCase {
    func test_prefersSavedAvatar_withoutDownloading() async throws {
        let favorites = FakeFavoritesRepository()
        favorites.avatars[1] = Data([9])
        let images = FakeImageRepository()
        images.data = Data([1])

        let data = await DefaultLoadAvatarUseCase(favorites: favorites, images: images).execute(for: .fixture())

        XCTAssertEqual(data, Data([9]))
        XCTAssertTrue(images.requestedURLs.isEmpty)
    }

    func test_downloadsWhenNothingSaved() async throws {
        let images = FakeImageRepository()
        images.data = Data([1])

        let data = await DefaultLoadAvatarUseCase(favorites: FakeFavoritesRepository(), images: images)
            .execute(for: .fixture())

        XCTAssertEqual(data, Data([1]))
    }
}

final class GetWeatherUseCaseTests: XCTestCase {
    private var weather: FakeWeatherRepository!
    private var favorites: FakeFavoritesRepository!
    private var useCase: DefaultGetWeatherUseCase!

    override func setUp() {
        super.setUp()
        weather = FakeWeatherRepository()
        favorites = FakeFavoritesRepository()
        useCase = DefaultGetWeatherUseCase(weather: weather, favorites: favorites)
    }

    func test_noCoordinate_throwsWithoutCallingTheNetwork() async {
        do {
            _ = try await useCase.execute(for: .fixture(coordinate: nil))
            XCTFail("expected an error")
        } catch {
            XCTAssertEqual(error as? WeatherError, .noCoordinate)
            XCTAssertTrue(weather.requested.isEmpty)
        }
    }

    func test_success_returnsFreshWeather_andDoesNotSaveForNonFavourites() async throws {
        let result = try await useCase.execute(for: .fixture())

        XCTAssertEqual(result, WeatherResult(weather: .fixture, staleSince: nil))
        XCTAssertTrue(favorites.weather.isEmpty)
    }

    func test_success_savesWeatherForFavourites() async throws {
        try await favorites.add(.fixture())

        _ = try await useCase.execute(for: .fixture())

        XCTAssertEqual(favorites.weather[1]?.weather, .fixture)
    }

    func test_failure_fallsBackToSavedWeather() async throws {
        try await favorites.add(.fixture())
        let saved = Date(timeIntervalSince1970: 500)
        favorites.weather[1] = CachedWeather(weather: .fixture, updatedAt: saved)
        weather.result = .failure(TestError())

        let result = try await useCase.execute(for: .fixture())

        XCTAssertEqual(result, WeatherResult(weather: .fixture, staleSince: saved))
    }

    func test_failure_withNothingSaved_throwsUnavailable() async {
        weather.result = .failure(TestError())
        do {
            _ = try await useCase.execute(for: .fixture())
            XCTFail("expected an error")
        } catch {
            XCTAssertEqual(error as? WeatherError, .unavailable(message: "boom", userIsFavorite: false))
        }
    }
}

final class FetchUsersUseCaseTests: XCTestCase {
    func test_returnsRepositoryUsers() async throws {
        let repository = FakeUserRepository()
        repository.result = .success([.fixture(id: 1), .fixture(id: 2)])
        let users = try await DefaultFetchUsersUseCase(users: repository).execute()
        XCTAssertEqual(users.map(\.id), [1, 2])
    }

    func test_propagatesErrors() async {
        let repository = FakeUserRepository()
        repository.result = .failure(TestError())
        do {
            _ = try await DefaultFetchUsersUseCase(users: repository).execute()
            XCTFail("expected an error")
        } catch {
            XCTAssertTrue(error is TestError)
        }
    }
}
