import Domain
import Foundation

/// What a list-style screen should currently show. The view just switches on it.
enum ScreenState: Equatable {
    case loading
    case content
    case empty(message: String)
    case error(message: String)
}

/// Display-ready data for one row in a user list.
struct UserRowViewModel: Identifiable, Equatable {
    let id: Int
    /// Carried so the view can navigate with it (SwiftUI routes by value).
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
