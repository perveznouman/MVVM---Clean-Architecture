import Domain
import Foundation

/// Mirrors the JSONPlaceholder `/users` payload exactly. Never leaves the Data layer.
struct UserDTO: Decodable {
    struct AddressDTO: Decodable {
        struct GeoDTO: Decodable {
            let lat: String
            let lng: String
        }
        let street: String
        let suite: String
        let city: String
        let zipcode: String
        let geo: GeoDTO
    }

    struct CompanyDTO: Decodable {
        let name: String
        let catchPhrase: String
        let bs: String
    }

    let id: Int
    let name: String
    let username: String
    let email: String
    let address: AddressDTO
    let phone: String
    let website: String
    let company: CompanyDTO
}

extension UserDTO {
    /// JSONPlaceholder has no pictures, so the avatar URL is derived from the id.
    static func avatarURL(forUserID id: Int) -> URL? {
        URL(string: "https://i.pravatar.cc/300?img=\(id)")
    }

    func toDomain() -> User {
        // The API sends coordinates as strings; anything unparsable becomes "no coordinate".
        let coordinate: Coordinate? = {
            guard let lat = Double(address.geo.lat), let lng = Double(address.geo.lng) else { return nil }
            return Coordinate(latitude: lat, longitude: lng)
        }()
        return User(
            id: id, name: name, username: username, email: email, phone: phone, website: website,
            address: Address(street: address.street, suite: address.suite, city: address.city,
                             zipcode: address.zipcode, coordinate: coordinate),
            company: Company(name: company.name, catchPhrase: company.catchPhrase, bs: company.bs),
            avatarURL: Self.avatarURL(forUserID: id)
        )
    }
}
