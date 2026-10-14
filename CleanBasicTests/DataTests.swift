import XCTest
@testable import CleanBasic

/// Data: JSON mapping and the real UserDefaults storage (on a throw-away suite).
final class DataTests: XCTestCase {
    func test_userDTO_decodesAndMapsToEntity() throws {
        let json = #"""
        [{"id":1,"name":"Leanne Graham","username":"Bret","email":"Sincere@april.biz",
          "address":{"street":"Kulas Light","suite":"Apt. 556","city":"Gwenborough","zipcode":"92998-3874",
                     "geo":{"lat":"-37.3159","lng":"81.1496"}},
          "phone":"1-770-736-8031 x56442","website":"hildegard.org",
          "company":{"name":"ignored","catchPhrase":"ignored","bs":"ignored"}}]
        """#
        let dto = try JSONDecoder().decode([UserDTO].self, from: Data(json.utf8))[0]

        XCTAssertEqual(dto.toDomain(), User(
            id: 1, name: "Leanne Graham", username: "Bret", email: "Sincere@april.biz",
            phone: "1-770-736-8031 x56442", website: "hildegard.org",
            address: Address(street: "Kulas Light", suite: "Apt. 556", city: "Gwenborough", zipcode: "92998-3874"),
            avatarURL: URL(string: "https://i.pravatar.cc/300?img=1")))
    }

    // MARK: Favourites storage

    private var suiteName = ""
    private var defaults: UserDefaults!
    private var repository: FavoritesRepositoryDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "tests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        repository = FavoritesRepositoryDefaults(defaults: defaults)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func test_startsEmpty() async {
        var iterator = repository.observeFavorites().makeAsyncIterator()
        let first = await iterator.next()
        XCTAssertEqual(first, [])
    }

    func test_addAndRemove() async {
        await repository.add(makeUser(1))
        let afterAdd = await repository.isFavorite(id: 1)
        XCTAssertTrue(afterAdd)

        await repository.remove(id: 1)
        let afterRemove = await repository.isFavorite(id: 1)
        XCTAssertFalse(afterRemove)
    }

    func test_addingTwice_keepsOne_andNewestIsFirst() async {
        await repository.add(makeUser(1))
        await repository.add(makeUser(1))
        await repository.add(makeUser(2))

        var iterator = repository.observeFavorites().makeAsyncIterator()
        let favorites = await iterator.next()
        XCTAssertEqual(favorites?.map(\.id), [2, 1])
    }

    func test_favouritesSurviveANewRepositoryInstance() async {
        await repository.add(makeUser(5))

        let reopened = FavoritesRepositoryDefaults(defaults: defaults) // like relaunching the app
        var iterator = reopened.observeFavorites().makeAsyncIterator()
        let favorites = await iterator.next()
        XCTAssertEqual(favorites, [makeUser(5)])
    }

    func test_watchersAreToldAboutChanges() async {
        var iterator = repository.observeFavorites().makeAsyncIterator()
        let initial = await iterator.next()
        XCTAssertEqual(initial, [])

        await repository.add(makeUser(3))
        let afterAdd = await iterator.next()
        XCTAssertEqual(afterAdd?.map(\.id), [3])

        await repository.remove(id: 3)
        let afterRemove = await iterator.next()
        XCTAssertEqual(afterRemove, [])
    }
}
