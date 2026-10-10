import Foundation

// ENTITIES: enterprise-wide business objects. Plain Swift: no Codable, no UIKit/SwiftUI, no Core Data.
// How they travel over the wire or sit on disk is the Data layer's problem (see DTOs and mappers there).

public struct User: Identifiable, Equatable, Hashable, Sendable {
    public let id: Int
    public let name: String
    public let username: String
    public let email: String
    public let phone: String
    public let website: String
    public let address: Address
    public let company: Company
    public let avatarURL: URL?

    public init(id: Int, name: String, username: String, email: String, phone: String, website: String,
                address: Address, company: Company, avatarURL: URL?) {
        self.id = id
        self.name = name
        self.username = username
        self.email = email
        self.phone = phone
        self.website = website
        self.address = address
        self.company = company
        self.avatarURL = avatarURL
    }
}

public struct Address: Equatable, Hashable, Sendable {
    public let street: String
    public let suite: String
    public let city: String
    public let zipcode: String
    /// `nil` when the source data had no usable coordinates.
    public let coordinate: Coordinate?

    public init(street: String, suite: String, city: String, zipcode: String, coordinate: Coordinate?) {
        self.street = street
        self.suite = suite
        self.city = city
        self.zipcode = zipcode
        self.coordinate = coordinate
    }
}

public struct Coordinate: Equatable, Hashable, Sendable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

public struct Company: Equatable, Hashable, Sendable {
    public let name: String
    public let catchPhrase: String
    public let bs: String

    public init(name: String, catchPhrase: String, bs: String) {
        self.name = name
        self.catchPhrase = catchPhrase
        self.bs = bs
    }
}
