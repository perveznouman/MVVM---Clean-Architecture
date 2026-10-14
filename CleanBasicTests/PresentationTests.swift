import XCTest
@testable import CleanBasic

/// Presentation: view models, tested with fake use cases.
@MainActor
final class PresentationTests: XCTestCase {
    private var getUsers: FakeGetUsers!
    private var observe: FakeObserveFavorites!
    private var toggle: FakeToggleFavorite!
    private var usersViewModel: UsersViewModel!

    override func setUp() {
        super.setUp()
        getUsers = FakeGetUsers()
        observe = FakeObserveFavorites()
        toggle = FakeToggleFavorite()
        usersViewModel = UsersViewModel(getUsers: getUsers, observeFavorites: observe, toggleFavorite: toggle)
    }

    // MARK: Users tab

    func test_startsLoading() {
        XCTAssertEqual(usersViewModel.state, .loading)
    }

    func test_load_success_formatsRows() async {
        getUsers.result = .success([makeUser(1, "Amy")])
        await usersViewModel.load()

        XCTAssertEqual(usersViewModel.state, .loaded)
        XCTAssertEqual(usersViewModel.rows, [UserRow(user: makeUser(1, "Amy"), isFavorite: false)])
        XCTAssertEqual(usersViewModel.rows.first?.username, "@u1")
    }

    func test_load_failure_showsMessage() async {
        getUsers.result = .failure(TestError())
        await usersViewModel.load()
        XCTAssertEqual(usersViewModel.state, .failed("boom"))
    }

    func test_failedRefresh_keepsExistingUsers() async {
        getUsers.result = .success([makeUser(1)])
        await usersViewModel.load()
        getUsers.result = .failure(TestError())
        await usersViewModel.load()

        XCTAssertEqual(usersViewModel.state, .loaded)
        XCTAssertEqual(usersViewModel.rows.count, 1)
    }

    func test_favouritesStream_marksRows() async {
        getUsers.result = .success([makeUser(1), makeUser(2)])
        observe.snapshots = [[], [makeUser(2)]]
        await usersViewModel.load()

        await usersViewModel.observeFavoriteChanges()

        XCTAssertEqual(usersViewModel.rows.map(\.isFavorite), [false, true])
    }

    func test_toggleFavorite_runsTheUseCaseForThatUser() async {
        getUsers.result = .success([makeUser(1), makeUser(2)])
        await usersViewModel.load()

        await usersViewModel.toggleFavorite(id: 2)

        XCTAssertEqual(toggle.toggled.map(\.id), [2])
    }

    // MARK: Favourites tab

    func test_favouritesTab_showsTheStreamAsStarredRows() async {
        observe.snapshots = [[makeUser(2), makeUser(1)]]
        let viewModel = FavoritesViewModel(observeFavorites: observe, toggleFavorite: toggle)
        XCTAssertTrue(viewModel.rows.isEmpty)

        await viewModel.observeFavoriteChanges()

        XCTAssertEqual(viewModel.rows.map(\.id), [2, 1])
        XCTAssertTrue(viewModel.rows.allSatisfy(\.isFavorite))
    }

    func test_favouritesTab_removeTogglesTheUser() async {
        observe.snapshots = [[makeUser(1)]]
        let viewModel = FavoritesViewModel(observeFavorites: observe, toggleFavorite: toggle)
        await viewModel.observeFavoriteChanges()

        await viewModel.toggleFavorite(id: 1)

        XCTAssertEqual(toggle.toggled.map(\.id), [1])
    }
}
