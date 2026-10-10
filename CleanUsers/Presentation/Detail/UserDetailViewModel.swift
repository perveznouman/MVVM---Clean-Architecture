import Domain
import Foundation
import Observation

@MainActor @Observable
final class UserDetailViewModel {
    struct Field: Equatable {
        let title: String
        let value: String
    }

    private(set) var isFavorite = false
    private(set) var avatarData: Data?
    private(set) var isLoadingAvatar = false

    let user: User
    let title: String
    let name: String
    let fields: [Field]
    let addressText: String

    private let observeFavorites: ObserveFavoritesUseCase
    private let toggleFavorite: ToggleFavoriteUseCase
    private let loadAvatar: LoadAvatarUseCase

    init(user: User, observeFavorites: ObserveFavoritesUseCase, toggleFavorite: ToggleFavoriteUseCase,
         loadAvatar: LoadAvatarUseCase) {
        self.user = user
        self.observeFavorites = observeFavorites
        self.toggleFavorite = toggleFavorite
        self.loadAvatar = loadAvatar

        title = user.name
        name = user.name
        fields = [
            Field(title: "Name", value: user.name),
            Field(title: "Username", value: "@\(user.username)"),
            Field(title: "Email", value: user.email),
            Field(title: "Phone", value: user.phone),
            Field(title: "Website", value: user.website)
        ]
        addressText = "\(user.address.suite), \(user.address.street), \(user.address.city) \(user.address.zipcode)"
    }

    func observeFavoriteChanges() async {
        for await favorites in observeFavorites.execute() {
            isFavorite = favorites.contains { $0.id == user.id }
        }
    }

    func loadAvatarIfNeeded() async {
        guard avatarData == nil else { return }
        isLoadingAvatar = true
        avatarData = await loadAvatar.execute(for: user)
        isLoadingAvatar = false
    }

    func toggleFavoriteTapped() async {
        _ = try? await toggleFavorite.execute(user)
    }
}
