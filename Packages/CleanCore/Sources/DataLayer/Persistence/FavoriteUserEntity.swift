import CoreData
import Domain
import Foundation

@objc(FavoriteUserEntity)
final class FavoriteUserEntity: NSManagedObject {
    @NSManaged var id: Int64
    @NSManaged var name: String?
    @NSManaged var username: String?
    @NSManaged var email: String?
    @NSManaged var phone: String?
    @NSManaged var website: String?
    @NSManaged var street: String?
    @NSManaged var suite: String?
    @NSManaged var city: String?
    @NSManaged var zipcode: String?
    @NSManaged var hasCoordinate: Bool
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var companyName: String?
    @NSManaged var companyCatchPhrase: String?
    @NSManaged var companyBs: String?
    @NSManaged var avatarURLString: String?
    @NSManaged var avatarData: Data?
    @NSManaged var weatherData: Data?
    @NSManaged var weatherUpdatedAt: Date?
    @NSManaged var addedAt: Date?

    @nonobjc class func fetchRequest() -> NSFetchRequest<FavoriteUserEntity> {
        NSFetchRequest<FavoriteUserEntity>(entityName: "FavoriteUserEntity")
    }
}

// MARK: Mapping between the managed object and the domain entity

extension FavoriteUserEntity {
    func apply(_ user: User) {
        id = Int64(user.id)
        name = user.name
        username = user.username
        email = user.email
        phone = user.phone
        website = user.website
        street = user.address.street
        suite = user.address.suite
        city = user.address.city
        zipcode = user.address.zipcode
        hasCoordinate = user.address.coordinate != nil
        latitude = user.address.coordinate?.latitude ?? 0
        longitude = user.address.coordinate?.longitude ?? 0
        companyName = user.company.name
        companyCatchPhrase = user.company.catchPhrase
        companyBs = user.company.bs
        avatarURLString = user.avatarURL?.absoluteString
    }

    func toDomain() -> User {
        User(
            id: Int(id), name: name ?? "", username: username ?? "", email: email ?? "",
            phone: phone ?? "", website: website ?? "",
            address: Address(
                street: street ?? "", suite: suite ?? "", city: city ?? "", zipcode: zipcode ?? "",
                coordinate: hasCoordinate ? Coordinate(latitude: latitude, longitude: longitude) : nil),
            company: Company(name: companyName ?? "", catchPhrase: companyCatchPhrase ?? "", bs: companyBs ?? ""),
            avatarURL: avatarURLString.flatMap(URL.init(string:))
        )
    }
}
