import Foundation

// DATA layer: talks to the outside world and implements the Domain's protocols.

/// DTO (Data Transfer Object): mirrors the JSON from the API. It is NOT our entity.
/// If the API changes, only this file and its mapping change, not the Domain or the UI.
struct UserDTO: Decodable {
    struct AddressDTO: Decodable {
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
    let address: AddressDTO

    /// Mapper: API shape -> our entity.
    func toDomain() -> User {
        User(
            id: id, name: name, username: username, email: email, phone: phone, website: website,
            address: Address(street: address.street, suite: address.suite, city: address.city, zipcode: address.zipcode),
            // This API has no profile pictures, so we build the URL of a free avatar service from the id.
            avatarURL: URL(string: "https://i.pravatar.cc/300?img=\(id)")
        )
    }
}
