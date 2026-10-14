import Foundation
import Observation

// PRESENTATION layer: what the screen shows. It depends on the Domain (use cases + entities), never on Data.

/// VIEW MODEL for the "Users" tab: holds the screen's state and prepares data for display.
/// `@Observable` lets SwiftUI redraw automatically when something it read here changes.
@MainActor @Observable
final class UsersViewModel {
    enum State: Equatable {
        case loading
        case loaded
        case failed(String)
    }

    private(set) var state: State = .loading
    private(set) var users: [User] = []
    private(set) var favoriteIDs: Set<Int> = []

    private let getUsers: GetUsersUseCase
    private let observeFavorites: ObserveFavoritesUseCase
    private let toggleFavorite: ToggleFavoriteUseCase

    init(getUsers: GetUsersUseCase, observeFavorites: ObserveFavoritesUseCase, toggleFavorite: ToggleFavoriteUseCase) {
        self.getUsers = getUsers
        self.observeFavorites = observeFavorites
        self.toggleFavorite = toggleFavorite
    }

    /// The rows on screen: every user, marked if they are a favourite.
    var rows: [UserRow] {
        users.map { UserRow(user: $0, isFavorite: favoriteIDs.contains($0.id)) }
    }

    /// Fetches users only if we don't have them yet (the tab can appear many times).
    func loadIfNeeded() async {
        guard users.isEmpty else { return }
        await load()
    }

    func load() async {
        if users.isEmpty { state = .loading }
        do {
            users = try await getUsers.execute()
            state = .loaded
        } catch {
            // A failed refresh keeps the users we already have; only show the error when there is nothing to show.
            if users.isEmpty { state = .failed(error.localizedDescription) }
        }
    }

    /// Keeps `favoriteIDs` up to date. Runs while the screen is visible (started from `.task`).
    func observeFavoriteChanges() async {
        for await favorites in observeFavorites.execute() {
            favoriteIDs = Set(favorites.map(\.id))
        }
    }

    func toggleFavorite(id: Int) async {
        guard let user = users.first(where: { $0.id == id }) else { return }
        await toggleFavorite.execute(user)
    }
}
