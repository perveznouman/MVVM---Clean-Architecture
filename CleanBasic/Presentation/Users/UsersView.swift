import SwiftUI

/// VIEW for the "Users" tab: draws whatever the view model says. No logic, no networking.
struct UsersView: View {
    @State private var viewModel: UsersViewModel
    /// How to build the detail screen for a user. Given by the composition root, so this view never creates view models itself.
    private let makeDetailViewModel: (User) -> UserDetailViewModel

    init(viewModel: UsersViewModel, makeDetailViewModel: @escaping (User) -> UserDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
        self.makeDetailViewModel = makeDetailViewModel
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Users")
                .navigationDestination(for: User.self) { user in
                    UserDetailView(viewModel: makeDetailViewModel(user))
                }
        }
        .task { await viewModel.loadIfNeeded() }
        .task { await viewModel.observeFavoriteChanges() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .failed(let message):
            ContentUnavailableView {
                Label("Couldn't Load Users", systemImage: "wifi.slash")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again") { Task { await viewModel.load() } }
            }
        case .loaded:
            List(viewModel.rows) { row in
                NavigationLink(value: row.user) {
                    UserRowView(row: row) {
                        Task { await viewModel.toggleFavorite(id: row.id) }
                    }
                }
            }
            .refreshable { await viewModel.load() }
        }
    }
}
