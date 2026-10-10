import Foundation

public enum WeatherError: Error, Equatable {
    /// The user's address has no usable coordinates.
    case noCoordinate
    /// No fresh data and nothing saved. `userIsFavorite` lets the UI suggest favouriting while online.
    case unavailable(message: String, userIsFavorite: Bool)
}

public protocol GetWeatherUseCase {
    func execute(for user: User) async throws -> WeatherResult
}

/// Business rules (these lived in the view model in MVVM):
/// 1. Fetch weather at the user's coordinate.
/// 2. If the user is a favourite, save the fresh report for offline use.
/// 3. If the fetch fails, fall back to the saved report; fail only if there is none.
public struct DefaultGetWeatherUseCase: GetWeatherUseCase {
    private let weather: WeatherRepository
    private let favorites: FavoritesRepository

    public init(weather: WeatherRepository, favorites: FavoritesRepository) {
        self.weather = weather
        self.favorites = favorites
    }

    public func execute(for user: User) async throws -> WeatherResult {
        guard let coordinate = user.address.coordinate else { throw WeatherError.noCoordinate }

        do {
            let fresh = try await weather.weather(at: coordinate)
            if await favorites.isFavorite(userID: user.id) {
                await favorites.saveWeather(fresh, for: user.id)
            }
            return WeatherResult(weather: fresh, staleSince: nil)
        } catch {
            if let cached = await favorites.cachedWeather(for: user.id) {
                return WeatherResult(weather: cached.weather, staleSince: cached.updatedAt)
            }
            throw WeatherError.unavailable(message: error.localizedDescription,
                                           userIsFavorite: await favorites.isFavorite(userID: user.id))
        }
    }
}
