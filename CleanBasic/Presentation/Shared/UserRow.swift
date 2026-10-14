import Foundation

/// Everything a row needs to draw one user, already formatted. Shared by both tabs.
struct UserRow: Identifiable, Equatable {
    let id: Int
    /// Kept so tapping the row can open that user's detail screen.
    let user: User
    let name: String
    let username: String
    let email: String
    let isFavorite: Bool

    init(user: User, isFavorite: Bool) {
        id = user.id
        self.user = user
        name = user.name
        username = "@\(user.username)"
        email = user.email
        self.isFavorite = isFavorite
    }
}
