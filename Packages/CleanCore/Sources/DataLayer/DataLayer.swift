import Domain

/// The Data layer's only public surface: a factory that returns the repositories as *Domain protocols*.
/// Every implementation type is internal, so no other module can depend on a concrete repository.
public struct Repositories {
    public let users: UserRepository
    public let weather: WeatherRepository
    public let images: ImageRepository
    public let favorites: FavoritesRepository
}

public enum DataLayer {
    public static func makeRepositories(inMemoryStore: Bool = false) -> Repositories {
        let client = URLSessionHTTPClient()
        let persistence = PersistenceController(inMemory: inMemoryStore)
        return Repositories(
            users: UserRepositoryImpl(client: client),
            weather: WeatherRepositoryImpl(client: client),
            images: ImageRepositoryImpl(client: client),
            favorites: FavoritesRepositoryImpl(container: persistence.container)
        )
    }
}
