import SwiftUI

/// VIEW for the "Favourites" tab.
struct FavoritesView: View {
    @State private var viewModel: FavoritesViewModel
    private let makeDetailViewModel: (User) -> UserDetailViewModel

    init(viewModel: FavoritesViewModel, makeDetailViewModel: @escaping (User) -> UserDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
        self.makeDetailViewModel = makeDetailViewModel
    }

    var body: some View {
        NavigationStack {
            List(viewModel.rows) { row in
                NavigationLink(value: row.user) {
                    UserRowView(row: row) {
                        Task { await viewModel.toggleFavorite(id: row.id) }
                    }
                }
            }
            .navigationDestination(for: User.self) { user in
                UserDetailView(viewModel: makeDetailViewModel(user))
            }
            .overlay {
                if viewModel.rows.isEmpty {
                    ContentUnavailableView("No Favourites", systemImage: "star",
                                           description: Text("Tap the star next to a user to save them here."))
                }
            }
            .navigationTitle("Favourites")
        }
        .task { await viewModel.observeFavoriteChanges() }
    }
}
