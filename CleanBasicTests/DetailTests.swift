import XCTest
@testable import CleanBasic

/// Presentation: the detail screen's view model, tested with fake use cases.
@MainActor
final class DetailTests: XCTestCase {
    private var observe: FakeObserveFavorites!
    private var toggle: FakeToggleFavorite!
    private var viewModel: UserDetailViewModel!

    override func setUp() {
        super.setUp()
        observe = FakeObserveFavorites()
        toggle = FakeToggleFavorite()
        viewModel = UserDetailViewModel(user: makeUser(1), observeFavorites: observe, toggleFavorite: toggle)
    }

    func test_fieldsAreFormattedForDisplay() {
        XCTAssertEqual(viewModel.fields.map(\.title), ["Name", "Username", "Email", "Phone", "Website", "Address"])
        XCTAssertEqual(viewModel.fields[1].value, "@u1")
        XCTAssertEqual(viewModel.fields[5].value, "Apt. 556, Kulas Light, Gwenborough 92998")
    }

    func test_exposesTheAvatarURLFromTheEntity() {
        XCTAssertEqual(viewModel.avatarURL, URL(string: "https://example.com/1.png"))
    }

    func test_isFavorite_followsTheStream() async {
        observe.snapshots = [[], [makeUser(1)]]
        XCTAssertFalse(viewModel.isFavorite)

        await viewModel.observeFavoriteChanges()

        XCTAssertTrue(viewModel.isFavorite)
    }

    func test_otherUsersBeingFavourite_doesNotMarkThisOne() async {
        observe.snapshots = [[makeUser(2)]]
        await viewModel.observeFavoriteChanges()
        XCTAssertFalse(viewModel.isFavorite)
    }

    func test_starTap_runsTheToggleUseCaseForThisUser() async {
        await viewModel.toggleFavoriteTapped()
        XCTAssertEqual(toggle.toggled.map(\.id), [1])
    }
}
