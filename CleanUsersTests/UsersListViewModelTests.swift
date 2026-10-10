import Domain
import XCTest
@testable import CleanUsers

@MainActor
final class UsersListViewModelTests: XCTestCase {
    private var fetch: FakeFetchUsers!
    private var observe: FakeObserveFavorites!
    private var toggle: FakeToggleFavorite!
    private var viewModel: UsersListViewModel!

    override func setUp() {
        super.setUp()
        fetch = FakeFetchUsers()
        observe = FakeObserveFavorites()
        toggle = FakeToggleFavorite()
        viewModel = UsersListViewModel(fetchUsers: fetch, observeFavorites: observe, toggleFavorite: toggle)
    }

    func test_initialState_isLoading() {
        XCTAssertEqual(viewModel.state, .loading)
        XCTAssertTrue(viewModel.rows.isEmpty)
    }

    func test_load_success_buildsFormattedRows() async {
        fetch.result = .success([.fixture(id: 1), .fixture(id: 2, name: "Ervin Howell")])
        await viewModel.load()

        XCTAssertEqual(viewModel.state, .content)
        XCTAssertEqual(viewModel.rows.map(\.name), ["Leanne Graham", "Ervin Howell"])
        XCTAssertEqual(viewModel.rows.first?.username, "@user1")
    }

    func test_load_empty_showsEmptyState() async {
        await viewModel.load()
        XCTAssertEqual(viewModel.state, .empty(message: "No users found."))
    }

    func test_load_failure_showsErrorWithMessage() async {
        fetch.result = .failure(TestError())
        await viewModel.load()

        guard case .error(let message) = viewModel.state else { return XCTFail("expected error, got \(viewModel.state)") }
        XCTAssertTrue(message.contains("boom"))
    }

    func test_refreshFailure_keepsExistingRows() async {
        fetch.result = .success([.fixture()])
        await viewModel.load()
        fetch.result = .failure(TestError())
        await viewModel.load()

        XCTAssertEqual(viewModel.state, .content)
        XCTAssertEqual(viewModel.rows.count, 1)
    }

    func test_favouritesStream_marksRows() async {
        fetch.result = .success([.fixture(id: 1), .fixture(id: 2)])
        observe.snapshots = [[], [.fixture(id: 2)]]
        await viewModel.load()

        await viewModel.observeFavoriteChanges()

        XCTAssertEqual(viewModel.rows.map(\.isFavorite), [false, true])
    }

    func test_toggleFavorite_runsTheUseCaseForThatUser() async {
        fetch.result = .success([.fixture(id: 1), .fixture(id: 2)])
        await viewModel.load()

        await viewModel.toggleFavorite(id: 2)

        XCTAssertEqual(toggle.toggled.map(\.id), [2])
    }

    func test_toggleFavorite_unknownID_doesNothing() async {
        await viewModel.toggleFavorite(id: 99)
        XCTAssertTrue(toggle.toggled.isEmpty)
    }
}
