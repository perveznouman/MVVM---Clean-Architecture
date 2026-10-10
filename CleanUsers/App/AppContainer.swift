import DataLayer
import Domain
import Observation

/// COMPOSITION ROOT: the only place that sees every layer. It builds repositories (Data), wraps them in use cases
/// (Domain) and hands those to view models (Presentation). Views receive it through the SwiftUI environment and
/// ask it for their view model.
@MainActor @Observable
final class AppContainer {
    private let fetchUsers: FetchUsersUseCase
    private let observeFavorites: ObserveFavoritesUseCase
    private let toggleFavorite: ToggleFavoriteUseCase
    private let loadAvatar: LoadAvatarUseCase
    private let getWeather: GetWeatherUseCase

    init(inMemoryStore: Bool = false) {
        let repositories = DataLayer.makeRepositories(inMemoryStore: inMemoryStore)
        fetchUsers = DefaultFetchUsersUseCase(users: repositories.users)
        observeFavorites = DefaultObserveFavoritesUseCase(favorites: repositories.favorites)
        toggleFavorite = DefaultToggleFavoriteUseCase(favorites: repositories.favorites, images: repositories.images)
        loadAvatar = DefaultLoadAvatarUseCase(favorites: repositories.favorites, images: repositories.images)
        getWeather = DefaultGetWeatherUseCase(weather: repositories.weather, favorites: repositories.favorites)
    }

    func makeUsersListViewModel() -> UsersListViewModel {
        UsersListViewModel(fetchUsers: fetchUsers, observeFavorites: observeFavorites, toggleFavorite: toggleFavorite)
    }

    func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(observeFavorites: observeFavorites, toggleFavorite: toggleFavorite)
    }

    func makeUserDetailViewModel(user: User) -> UserDetailViewModel {
        UserDetailViewModel(user: user, observeFavorites: observeFavorites,
                            toggleFavorite: toggleFavorite, loadAvatar: loadAvatar)
    }

    func makeWeatherViewModel(user: User) -> WeatherViewModel {
        WeatherViewModel(user: user, getWeather: getWeather)
    }
}
