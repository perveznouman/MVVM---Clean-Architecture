import Domain
import Foundation
import Observation

/// PRESENTATION: formats and holds screen state. All business actions go through use cases;
/// it knows nothing about repositories, networking or Core Data.
@MainActor @Observable
final class UsersListViewModel {
    private(set) var state: ScreenState = .loading
    private(set) var users: [User] = []
    private(set) var favoriteIDs: Set<Int> = []

    let title = "Users"

    private let fetchUsers: FetchUsersUseCase
    private let observeFavorites: ObserveFavoritesUseCase
    private let toggleFavorite: ToggleFavoriteUseCase

    init(fetchUsers: FetchUsersUseCase, observeFavorites: ObserveFavoritesUseCase, toggleFavorite: ToggleFavoriteUseCase) {
        self.fetchUsers = fetchUsers
        self.observeFavorites = observeFavorites
        self.toggleFavorite = toggleFavorite
    }

    var rows: [UserRowViewModel] {
        users.map { UserRowViewModel(user: $0, isFavorite: favoriteIDs.contains($0.id)) }
    }

    /// Runs for as long as the screen is on display (call from `.task`; SwiftUI cancels it on disappear).
    func observeFavoriteChanges() async {
        for await favorites in observeFavorites.execute() {
            favoriteIDs = Set(favorites.map(\.id))
        }
    }

    /// For `.task`: SwiftUI runs it every time the view appears, so only fetch when we have nothing yet.
    func loadIfNeeded() async {
        guard users.isEmpty else { return }
        await load()
    }

    func load() async {
        if users.isEmpty { state = .loading }
        do {
            users = try await fetchUsers.execute()
            state = users.isEmpty ? .empty(message: "No users found.") : .content
        } catch {
            // Keep showing stale rows on a refresh failure; only show the error when there is nothing to show.
            if users.isEmpty {
                state = .error(message: "Couldn't load users.\n\(error.localizedDescription)\n\nFavourites are still available offline.")
            }
        }
    }

    func toggleFavorite(id: Int) async {
        guard let user = users.first(where: { $0.id == id }) else { return }
        _ = try? await toggleFavorite.execute(user)
    }
}
