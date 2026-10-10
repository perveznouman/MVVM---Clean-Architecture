import Foundation

// USE CASES: one application-specific business action each. Presentation calls these; it never touches
// repositories directly. Each is a protocol (so view models can be tested with fakes) plus a default implementation.

// MARK: Fetch users

public protocol FetchUsersUseCase {
    func execute() async throws -> [User]
}

public struct DefaultFetchUsersUseCase: FetchUsersUseCase {
    private let users: UserRepository

    public init(users: UserRepository) {
        self.users = users
    }

    public func execute() async throws -> [User] {
        try await users.fetchUsers()
    }
}

// MARK: Observe favourites

public protocol ObserveFavoritesUseCase {
    func execute() -> AsyncStream<[User]>
}

public struct DefaultObserveFavoritesUseCase: ObserveFavoritesUseCase {
    private let favorites: FavoritesRepository

    public init(favorites: FavoritesRepository) {
        self.favorites = favorites
    }

    public func execute() -> AsyncStream<[User]> {
        favorites.observeFavorites()
    }
}

// MARK: Toggle favourite

public protocol ToggleFavoriteUseCase {
    /// Returns whether the user is a favourite *after* the toggle.
    @discardableResult
    func execute(_ user: User) async throws -> Bool
}

/// Business rule: favouriting a user also saves their avatar so the profile works offline.
public struct DefaultToggleFavoriteUseCase: ToggleFavoriteUseCase {
    private let favorites: FavoritesRepository
    private let images: ImageRepository

    public init(favorites: FavoritesRepository, images: ImageRepository) {
        self.favorites = favorites
        self.images = images
    }

    public func execute(_ user: User) async throws -> Bool {
        if await favorites.isFavorite(userID: user.id) {
            try await favorites.remove(userID: user.id)
            return false
        }
        try await favorites.add(user)
        // The user is already a favourite (observers have been told); the avatar follows when it arrives.
        if let url = user.avatarURL, let data = await images.imageData(from: url) {
            await favorites.saveAvatarData(data, for: user.id)
        }
        return true
    }
}

// MARK: Load avatar

public protocol LoadAvatarUseCase {
    func execute(for user: User) async -> Data?
}

/// Business rule: prefer the saved avatar (works offline); otherwise download it.
public struct DefaultLoadAvatarUseCase: LoadAvatarUseCase {
    private let favorites: FavoritesRepository
    private let images: ImageRepository

    public init(favorites: FavoritesRepository, images: ImageRepository) {
        self.favorites = favorites
        self.images = images
    }

    public func execute(for user: User) async -> Data? {
        if let saved = await favorites.avatarData(for: user.id) { return saved }
        guard let url = user.avatarURL else { return nil }
        return await images.imageData(from: url)
    }
}
