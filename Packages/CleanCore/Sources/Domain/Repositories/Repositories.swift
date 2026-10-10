import Foundation

// REPOSITORY PROTOCOLS: the contracts the use cases need. They live in the Domain (the inner layer) and are
// implemented by the Data layer (the outer layer). This inversion is what makes the Domain independent of
// networking and persistence.

public protocol UserRepository {
    func fetchUsers() async throws -> [User]
}

public protocol WeatherRepository {
    func weather(at coordinate: Coordinate) async throws -> Weather
}

public protocol ImageRepository {
    func imageData(from url: URL) async -> Data?
}

public protocol FavoritesRepository {
    /// Emits the current favourites immediately, then again after every add / remove (newest first).
    func observeFavorites() -> AsyncStream<[User]>
    func isFavorite(userID: Int) async -> Bool
    func add(_ user: User) async throws
    func remove(userID: Int) async throws

    func avatarData(for userID: Int) async -> Data?
    func saveAvatarData(_ data: Data, for userID: Int) async

    func cachedWeather(for userID: Int) async -> CachedWeather?
    func saveWeather(_ weather: Weather, for userID: Int) async
}
