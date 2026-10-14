import Foundation

/// How a favourite user is SAVED on the device. It is separate from `UserDTO` (how the API sends users),
/// so changing the API format can never break data already saved on a phone.
struct StoredUserDTO: Codable {
    struct StoredAddress: Codable {
        let street: String
        let suite: String
        let city: String
        let zipcode: String
    }

    let id: Int
    let name: String
    let username: String
    let email: String
    let phone: String
    let website: String
    let address: StoredAddress
    let avatarURL: URL?

    init(_ user: User) {
        id = user.id
        name = user.name
        username = user.username
        email = user.email
        phone = user.phone
        website = user.website
        address = StoredAddress(street: user.address.street, suite: user.address.suite,
                                city: user.address.city, zipcode: user.address.zipcode)
        avatarURL = user.avatarURL
    }

    func toDomain() -> User {
        User(id: id, name: name, username: username, email: email, phone: phone, website: website,
             address: Address(street: address.street, suite: address.suite, city: address.city, zipcode: address.zipcode),
             avatarURL: avatarURL)
    }
}
