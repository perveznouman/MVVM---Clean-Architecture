import CoreData
import Domain
import Foundation

/// Core Data implementation of the Domain's `FavoritesRepository`.
/// Works on a private background context, so no disk I/O happens on the main thread.
final class FavoritesRepositoryImpl: FavoritesRepository, @unchecked Sendable {
    private let context: NSManagedObjectContext
    private let broadcaster = Broadcaster<[User]>()

    init(container: NSPersistentContainer) {
        context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    // MARK: Observing

    func observeFavorites() -> AsyncStream<[User]> {
        broadcaster.stream { [self] in await allFavorites() }
    }

    // MARK: Favourites

    func isFavorite(userID: Int) async -> Bool {
        await context.perform { [self] in entity(for: userID) != nil }
    }

    func add(_ user: User) async throws {
        try await context.perform { [self] in
            guard entity(for: user.id) == nil else { return }
            let entity = FavoriteUserEntity(context: context)
            entity.apply(user)
            entity.addedAt = Date()
            try context.save()
        }
        await publishChange()
    }

    func remove(userID: Int) async throws {
        try await context.perform { [self] in
            guard let entity = entity(for: userID) else { return }
            context.delete(entity)
            try context.save()
        }
        await publishChange()
    }

    // MARK: Offline extras (no change notification: lists don't show them)

    func avatarData(for userID: Int) async -> Data? {
        await context.perform { [self] in entity(for: userID)?.avatarData }
    }

    func saveAvatarData(_ data: Data, for userID: Int) async {
        await context.perform { [self] in
            guard let entity = entity(for: userID) else { return }
            entity.avatarData = data
            try? context.save()
        }
    }

    func cachedWeather(for userID: Int) async -> CachedWeather? {
        await context.perform { [self] in
            guard let entity = entity(for: userID),
                  let data = entity.weatherData,
                  let date = entity.weatherUpdatedAt,
                  let stored = try? JSONDecoder().decode(WeatherCacheDTO.self, from: data) else { return nil }
            return CachedWeather(weather: stored.toDomain(), updatedAt: date)
        }
    }

    func saveWeather(_ weather: Weather, for userID: Int) async {
        await context.perform { [self] in
            guard let entity = entity(for: userID),
                  let data = try? JSONEncoder().encode(WeatherCacheDTO(weather)) else { return }
            entity.weatherData = data
            entity.weatherUpdatedAt = Date()
            try? context.save()
        }
    }

    // MARK: Private (call only inside `context.perform`)

    private func entity(for userID: Int) -> FavoriteUserEntity? {
        let request = FavoriteUserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", Int64(userID))
        request.fetchLimit = 1
        return (try? context.fetch(request))?.first
    }

    private func allFavorites() async -> [User] {
        await context.perform { [self] in
            let request = FavoriteUserEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "addedAt", ascending: false)]
            return ((try? context.fetch(request)) ?? []).map { $0.toDomain() }
        }
    }

    private func publishChange() async {
        broadcaster.send(await allFavorites())
    }
}
