import Domain
import XCTest
@testable import CleanUsers

@MainActor
final class FavoritesViewModelTests: XCTestCase {
    func test_noFavourites_showsEmptyState() {
        let viewModel = FavoritesViewModel(observeFavorites: FakeObserveFavorites(), toggleFavorite: FakeToggleFavorite())
        guard case .empty = viewModel.state else { return XCTFail("expected empty, got \(viewModel.state)") }
    }

    func test_rowsFollowTheFavouritesStream() async {
        let observe = FakeObserveFavorites()
        observe.snapshots = [[.fixture(id: 1)], [.fixture(id: 2, name: "Ervin Howell"), .fixture(id: 1)]]
        let viewModel = FavoritesViewModel(observeFavorites: observe, toggleFavorite: FakeToggleFavorite())

        await viewModel.observeFavoriteChanges()

        XCTAssertEqual(viewModel.state, .content)
        XCTAssertEqual(viewModel.rows.map(\.name), ["Ervin Howell", "Leanne Graham"])
        XCTAssertTrue(viewModel.rows.allSatisfy(\.isFavorite))
    }

    func test_remove_togglesTheUser() async {
        let observe = FakeObserveFavorites()
        observe.snapshots = [[.fixture(id: 1)]]
        let toggle = FakeToggleFavorite()
        let viewModel = FavoritesViewModel(observeFavorites: observe, toggleFavorite: toggle)
        await viewModel.observeFavoriteChanges()

        await viewModel.remove(id: 1)

        XCTAssertEqual(toggle.toggled.map(\.id), [1])
    }
}

@MainActor
final class UserDetailViewModelTests: XCTestCase {
    private func makeViewModel(observe: FakeObserveFavorites = FakeObserveFavorites(),
                               toggle: FakeToggleFavorite = FakeToggleFavorite(),
                               avatar: FakeLoadAvatar = FakeLoadAvatar()) -> UserDetailViewModel {
        UserDetailViewModel(user: .fixture(), observeFavorites: observe, toggleFavorite: toggle, loadAvatar: avatar)
    }

    func test_fieldsAreFormatted() {
        let viewModel = makeViewModel()
        XCTAssertEqual(viewModel.fields.map(\.title), ["Name", "Username", "Email", "Phone", "Website"])
        XCTAssertEqual(viewModel.fields[1].value, "@user1")
        XCTAssertEqual(viewModel.addressText, "Apt. 556, Kulas Light, Gwenborough 92998")
    }

    func test_isFavorite_followsTheStream() async {
        let observe = FakeObserveFavorites()
        observe.snapshots = [[.fixture(id: 1)]]
        let viewModel = makeViewModel(observe: observe)
        XCTAssertFalse(viewModel.isFavorite)

        await viewModel.observeFavoriteChanges()

        XCTAssertTrue(viewModel.isFavorite)
    }

    func test_otherUsersFavourites_doNotMarkThisOne() async {
        let observe = FakeObserveFavorites()
        observe.snapshots = [[.fixture(id: 2)]]
        let viewModel = makeViewModel(observe: observe)
        await viewModel.observeFavoriteChanges()
        XCTAssertFalse(viewModel.isFavorite)
    }

    func test_loadsAvatarThroughTheUseCase() async {
        let avatar = FakeLoadAvatar()
        avatar.data = Data([7])
        let viewModel = makeViewModel(avatar: avatar)

        await viewModel.loadAvatarIfNeeded()

        XCTAssertEqual(viewModel.avatarData, Data([7]))
        XCTAssertFalse(viewModel.isLoadingAvatar)
    }

    func test_toggleFavouriteTapped_runsTheUseCase() async {
        let toggle = FakeToggleFavorite()
        await makeViewModel(toggle: toggle).toggleFavoriteTapped()
        XCTAssertEqual(toggle.toggled.map(\.id), [1])
    }
}
