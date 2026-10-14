import Foundation

// DOMAIN layer: the business. It imports only Foundation, so it knows nothing about
// SwiftUI, the network or the API's JSON.

/// ENTITY: what a "user" means in our app.
struct User: Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let phone: String
    let website: String
    let address: Address
    /// Where to find the profile picture. The Data layer decides what this URL is.
    let avatarURL: URL?
}

/// ENTITY: a postal address.
struct Address: Equatable, Hashable {
    let street: String
    let suite: String
    let city: String
    let zipcode: String
}
