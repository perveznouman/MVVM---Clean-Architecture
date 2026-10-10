import Domain
import SwiftUI

struct RootView: View {
    @Environment(AppContainer.self) private var container

    var body: some View {
        TabView {
            NavigationStack {
                UsersListView(viewModel: container.makeUsersListViewModel())
                    .routed()
            }
            .tabItem { Label("Users", systemImage: "person.3") }

            NavigationStack {
                FavoritesView(viewModel: container.makeFavoritesViewModel())
                    .routed()
            }
            .tabItem { Label("Favourites", systemImage: "star") }
        }
    }
}

private extension View {
    /// Registers how each `Route` becomes a screen. Each destination asks the container for its view model.
    func routed() -> some View {
        navigationDestination(for: Route.self) { route in
            RouteDestination(route: route)
        }
    }
}

private struct RouteDestination: View {
    @Environment(AppContainer.self) private var container
    let route: Route

    var body: some View {
        switch route {
        case .detail(let user):
            UserDetailView(viewModel: container.makeUserDetailViewModel(user: user))
        case .weather(let user):
            WeatherView(viewModel: container.makeWeatherViewModel(user: user))
        }
    }
}
