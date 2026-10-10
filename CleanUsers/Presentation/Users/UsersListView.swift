import SwiftUI

/// SCREEN 1. Reads the `@Observable` view model in `body`; SwiftUI re-renders when what it read changes.
struct UsersListView: View {
    // @State keeps the view model alive across body re-evaluations (the container creates it once per screen).
    @State private var viewModel: UsersListViewModel

    init(viewModel: UsersListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List(viewModel.rows) { row in
            NavigationLink(value: Route.detail(row.user)) {
                UserRowView(row: row)
            }
            .swipeActions {
                Button {
                    Task { await viewModel.toggleFavorite(id: row.id) }
                } label: {
                    Label(row.isFavorite ? "Unfavourite" : "Favourite",
                          systemImage: row.isFavorite ? "star.slash" : "star.fill")
                }
                .tint(.orange)
            }
        }
        .navigationTitle(viewModel.title)
        .overlay { stateOverlay }
        .task { await viewModel.observeFavoriteChanges() }
        .task { await viewModel.loadIfNeeded() }
        .refreshable { await viewModel.load() }
    }

    @ViewBuilder
    private var stateOverlay: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .content:
            EmptyView()
        case .empty(let message):
            ContentUnavailableView("No Users", systemImage: "person.slash", description: Text(message))
        case .error(let message):
            ContentUnavailableView {
                Label("Couldn't Load Users", systemImage: "wifi.slash")
            } description: {
                Text(message)
            } actions: {
                Button("Try Again") { Task { await viewModel.load() } }
            }
        }
    }
}
