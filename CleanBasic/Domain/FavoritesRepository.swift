import Foundation

/// REPOSITORY PROTOCOL for favourites: what the Domain needs to remember which users are favourites.
/// Again it only says WHAT; the Data layer decides HOW (UserDefaults today, Core Data tomorrow).
protocol FavoritesRepository {
    /// Gives the current favourites right away, then a fresh list every time one is added or removed.
    /// This is how the two tabs stay in sync without knowing about each other.
    func observeFavorites() -> AsyncStream<[User]>

    func isFavorite(id: Int) async -> Bool
    func add(_ user: User) async
    func remove(id: Int) async
}
