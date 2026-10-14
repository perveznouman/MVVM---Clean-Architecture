import SwiftUI

/// The two tabs.
struct RootView: View {
    let container: AppContainer

    var body: some View {
        TabView {
            UsersView(viewModel: container.usersViewModel,
                      makeDetailViewModel: container.makeUserDetailViewModel(user:))
                .tabItem { Label("Users", systemImage: "person.3") }

            FavoritesView(viewModel: container.favoritesViewModel,
                          makeDetailViewModel: container.makeUserDetailViewModel(user:))
                .tabItem { Label("Favourites", systemImage: "star") }
        }
    }
}
