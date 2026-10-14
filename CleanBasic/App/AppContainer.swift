import Foundation

/// COMPOSITION ROOT: the one place that knows every layer and connects them.
///
///   Data:          RemoteUserRepository, UserDefaultsFavoritesRepository
///   Domain:        use cases that wrap those repositories (the use cases only see the protocols)
///   Presentation:  view models that receive the use cases
///
/// Each object gets what it needs through its initialiser (dependency injection).
@MainActor
final class AppContainer {
    let usersViewModel: UsersViewModel
    let favoritesViewModel: FavoritesViewModel

    private let observeFavorites: ObserveFavoritesUseCase
    private let toggleFavorite: ToggleFavoriteUseCase

    init() {
        // One favourites repository, shared by both tabs, so they always agree.
        let favoritesRepository = FavoritesRepositoryDefaults()
        let observeFavorites = DefaultObserveFavoritesUseCase(repository: favoritesRepository)
        let toggleFavorite = DefaultToggleFavoriteUseCase(repository: favoritesRepository)
        self.observeFavorites = observeFavorites
        self.toggleFavorite = toggleFavorite

        usersViewModel = UsersViewModel(
            getUsers: DefaultGetUsersUseCase(repository: RemoteUserRepository()),
            observeFavorites: observeFavorites,
            toggleFavorite: toggleFavorite
        )
        favoritesViewModel = FavoritesViewModel(
            observeFavorites: observeFavorites,
            toggleFavorite: toggleFavorite
        )
    }

    /// A detail screen is created on demand, one per user that gets opened.
    func makeUserDetailViewModel(user: User) -> UserDetailViewModel {
        UserDetailViewModel(user: user, observeFavorites: observeFavorites, toggleFavorite: toggleFavorite)
    }
}
