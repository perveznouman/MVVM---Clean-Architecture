import Domain
import Foundation

extension User {
    static func fixture(id: Int = 1, name: String = "Leanne Graham",
                        coordinate: Coordinate? = Coordinate(latitude: -37.3159, longitude: 81.1496)) -> User {
        User(id: id, name: name, username: "user\(id)", email: "user\(id)@example.com", phone: "123",
             website: "example.org",
             address: Address(street: "Kulas Light", suite: "Apt. 556", city: "Gwenborough", zipcode: "92998",
                              coordinate: coordinate),
             company: Company(name: "Co", catchPhrase: "Phrase", bs: "bs"),
             avatarURL: URL(string: "https://example.com/\(id).png"))
    }
}

extension Weather {
    /// Day 0 = 2026-10-07, day 1 = 2026-10-08 (a Thursday), both at 00:00 UTC.
    static let fixture = Weather(
        current: .init(temperature: 12.4, apparentTemperature: 7.2, humidity: 70, windSpeed: 28.6, condition: .overcast),
        daily: [
            .init(date: Date(timeIntervalSince1970: 1_791_331_200), condition: .overcast, minTemperature: 10, maxTemperature: 12.6),
            .init(date: Date(timeIntervalSince1970: 1_791_417_600), condition: .rain, minTemperature: 11, maxTemperature: 13)
        ])
}

struct TestError: LocalizedError {
    var errorDescription: String? { "boom" }
}

// MARK: Fake use cases: the view models depend on these protocols, never on repositories.

final class FakeFetchUsers: FetchUsersUseCase {
    var result: Result<[User], Error> = .success([])
    func execute() async throws -> [User] { try result.get() }
}

/// Replays the given snapshots, then finishes, so `await viewModel.observeFavoriteChanges()` returns deterministically.
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
    func execute(_ user: User) async throws -> Bool {
        toggled.append(user)
        return true
    }
}

final class FakeLoadAvatar: LoadAvatarUseCase {
    var data: Data?
    func execute(for user: User) async -> Data? { data }
}

final class FakeGetWeather: GetWeatherUseCase {
    var result: Result<WeatherResult, Error> = .success(WeatherResult(weather: .fixture, staleSince: nil))
    private(set) var requestedUsers: [User] = []
    func execute(for user: User) async throws -> WeatherResult {
        requestedUsers.append(user)
        return try result.get()
    }
}
