import Foundation
import Observation

/// VIEW MODEL for the detail screen. It needs no new use case: it reuses the favourites ones.
@MainActor @Observable
final class UserDetailViewModel {
    struct Field: Equatable {
        let title: String
        let value: String
    }

    private(set) var isFavorite = false

    let title: String
    let name: String
    let avatarURL: URL?
    let fields: [Field]

    private let user: User
    private let observeFavorites: ObserveFavoritesUseCase
    private let toggleFavorite: ToggleFavoriteUseCase

    init(user: User, observeFavorites: ObserveFavoritesUseCase, toggleFavorite: ToggleFavoriteUseCase) {
        self.user = user
        self.observeFavorites = observeFavorites
        self.toggleFavorite = toggleFavorite

        title = user.name
        name = user.name
        avatarURL = user.avatarURL
        // Turning the entity into display text is Presentation's job, so it happens here.
        fields = [
            Field(title: "Name", value: user.name),
            Field(title: "Username", value: "@\(user.username)"),
            Field(title: "Email", value: user.email),
            Field(title: "Phone", value: user.phone),
            Field(title: "Website", value: user.website),
            Field(title: "Address",
                  value: "\(user.address.suite), \(user.address.street), \(user.address.city) \(user.address.zipcode)")
        ]
    }

    /// Keeps the star in sync, even if this user is favourited or unfavourited elsewhere.
    func observeFavoriteChanges() async {
        for await favorites in observeFavorites.execute() {
            isFavorite = favorites.contains { $0.id == user.id }
        }
    }

    func toggleFavoriteTapped() async {
        await toggleFavorite.execute(user)
    }
}
