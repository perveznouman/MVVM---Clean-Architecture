import Foundation

/// USE CASE: "watch the list of favourite users".
protocol ObserveFavoritesUseCase {
    func execute() -> AsyncStream<[User]>
}

struct DefaultObserveFavoritesUseCase: ObserveFavoritesUseCase {
    private let repository: FavoritesRepository

    init(repository: FavoritesRepository) {
        self.repository = repository
    }

    func execute() -> AsyncStream<[User]> {
        repository.observeFavorites()
    }
}

/// USE CASE: "tap the star". Business rule: a favourite becomes a non-favourite, and the other way round.
protocol ToggleFavoriteUseCase {
    func execute(_ user: User) async
}

struct DefaultToggleFavoriteUseCase: ToggleFavoriteUseCase {
    private let repository: FavoritesRepository

    init(repository: FavoritesRepository) {
        self.repository = repository
    }

    func execute(_ user: User) async {
        if await repository.isFavorite(id: user.id) {
            await repository.remove(id: user.id)
        } else {
            await repository.add(user)
        }
    }
}
