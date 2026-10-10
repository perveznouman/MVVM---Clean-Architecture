import SwiftUI

/// SCREEN 2. Favourites come from the Domain's favourites stream, backed by Core Data, so no network is needed.
struct FavoritesView: View {
    @State private var viewModel: FavoritesViewModel

    init(viewModel: FavoritesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List(viewModel.rows) { row in
            NavigationLink(value: Route.detail(row.user)) {
                UserRowView(row: row)
            }
            .swipeActions {
                Button(role: .destructive) {
                    Task { await viewModel.remove(id: row.id) }
                } label: {
                    Label("Remove", systemImage: "trash")
                }
            }
        }
        .navigationTitle(viewModel.title)
        .overlay {
            if case .empty(let message) = viewModel.state {
                ContentUnavailableView("No Favourites", systemImage: "star", description: Text(message))
            }
        }
        .task { await viewModel.observeFavoriteChanges() }
    }
}
