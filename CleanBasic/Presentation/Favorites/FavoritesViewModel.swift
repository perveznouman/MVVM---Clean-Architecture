import Foundation
import Observation

/// VIEW MODEL for the "Favourites" tab. It never fetches from the network: favourites are saved on the device.
@MainActor @Observable
final class FavoritesViewModel {
    private(set) var users: [User] = []

    private let observeFavorites: ObserveFavoritesUseCase
    private let toggleFavorite: ToggleFavoriteUseCase

    init(observeFavorites: ObserveFavoritesUseCase, toggleFavorite: ToggleFavoriteUseCase) {
        self.observeFavorites = observeFavorites
        self.toggleFavorite = toggleFavorite
    }

    var rows: [UserRow] {
        users.map { UserRow(user: $0, isFavorite: true) }
    }

    /// Updates the list whenever a favourite is added or removed (in either tab).
    func observeFavoriteChanges() async {
        for await favorites in observeFavorites.execute() {
            users = favorites
        }
    }

    /// Tapping the star here removes the user from favourites.
    func toggleFavorite(id: Int) async {
        guard let user = users.first(where: { $0.id == id }) else { return }
        await toggleFavorite.execute(user)
    }
}
