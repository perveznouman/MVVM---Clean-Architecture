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
    static let fixture = Weather(
        current: .init(temperature: 12, apparentTemperature: 7, humidity: 70, windSpeed: 28, condition: .overcast),
        daily: [.init(date: Date(timeIntervalSince1970: 0), condition: .rain, minTemperature: 10, maxTemperature: 13)])
}

struct TestError: LocalizedError {
    var errorDescription: String? { "boom" }
}

final class FakeUserRepository: UserRepository {
    var result: Result<[User], Error> = .success([])
    func fetchUsers() async throws -> [User] { try result.get() }
}

final class FakeWeatherRepository: WeatherRepository {
    var result: Result<Weather, Error> = .success(.fixture)
    private(set) var requested: [Coordinate] = []
    func weather(at coordinate: Coordinate) async throws -> Weather {
        requested.append(coordinate)
        return try result.get()
    }
}

final class FakeImageRepository: ImageRepository {
    var data: Data?
    private(set) var requestedURLs: [URL] = []
    func imageData(from url: URL) async -> Data? {
        requestedURLs.append(url)
        return data
    }
}

final class FakeFavoritesRepository: FavoritesRepository {
    private(set) var users: [User] = []
    var avatars: [Int: Data] = [:]
    var weather: [Int: CachedWeather] = [:]

    func observeFavorites() -> AsyncStream<[User]> {
        AsyncStream { continuation in
            continuation.yield(users)
            continuation.finish()
        }
    }

    func isFavorite(userID: Int) async -> Bool { users.contains { $0.id == userID } }
    func add(_ user: User) async throws { users.insert(user, at: 0) }
    func remove(userID: Int) async throws { users.removeAll { $0.id == userID } }
    func avatarData(for userID: Int) async -> Data? { avatars[userID] }
    func saveAvatarData(_ data: Data, for userID: Int) async { avatars[userID] = data }
    func cachedWeather(for userID: Int) async -> CachedWeather? { weather[userID] }
    func saveWeather(_ weather: Weather, for userID: Int) async {
        self.weather[userID] = CachedWeather(weather: weather, updatedAt: Date(timeIntervalSince1970: 1_000))
    }
}
