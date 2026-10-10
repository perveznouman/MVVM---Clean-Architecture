import Domain
import Foundation

final class UserRepositoryImpl: UserRepository {
    private let client: HTTPClient
    private let url = URL(string: "https://jsonplaceholder.typicode.com/users")!

    init(client: HTTPClient) {
        self.client = client
    }

    func fetchUsers() async throws -> [User] {
        try await client.get([UserDTO].self, from: url).map { $0.toDomain() }
    }
}

final class WeatherRepositoryImpl: WeatherRepository {
    private let client: HTTPClient

    init(client: HTTPClient) {
        self.client = client
    }

    func weather(at coordinate: Coordinate) async throws -> Weather {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(coordinate.latitude)),
            URLQueryItem(name: "longitude", value: String(coordinate.longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code"),
            URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min"),
            URLQueryItem(name: "timezone", value: "auto")
        ]
        guard let url = components.url else { throw APIError.invalidURL }
        return try await client.get(WeatherDTO.self, from: url).toDomain()
    }
}

final class ImageRepositoryImpl: ImageRepository {
    private let client: HTTPClient
    private let cache = NSCache<NSURL, NSData>()

    init(client: HTTPClient) {
        self.client = client
    }

    func imageData(from url: URL) async -> Data? {
        if let cached = cache.object(forKey: url as NSURL) { return cached as Data }
        guard let data = try? await client.data(from: url) else { return nil }
        cache.setObject(data as NSData, forKey: url as NSURL)
        return data
    }
}
