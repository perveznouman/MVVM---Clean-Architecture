import Domain
import Foundation
import Observation

@MainActor @Observable
final class FavoritesViewModel {
    private(set) var users: [User] = []

    let title = "Favourites"

    private let observeFavorites: ObserveFavoritesUseCase
    private let toggleFavorite: ToggleFavoriteUseCase

    init(observeFavorites: ObserveFavoritesUseCase, toggleFavorite: ToggleFavoriteUseCase) {
        self.observeFavorites = observeFavorites
        self.toggleFavorite = toggleFavorite
    }

    var rows: [UserRowViewModel] {
        users.map { UserRowViewModel(user: $0, isFavorite: true) }
    }

    var state: ScreenState {
        users.isEmpty
            ? .empty(message: "No favourites yet.\nOpen a user and tap the star to save them for offline use.")
            : .content
    }

    func observeFavoriteChanges() async {
        for await favorites in observeFavorites.execute() {
            users = favorites
        }
    }

    func remove(id: Int) async {
        guard let user = users.first(where: { $0.id == id }) else { return }
        _ = try? await toggleFavorite.execute(user)
    }
}
