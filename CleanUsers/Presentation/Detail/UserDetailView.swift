import SwiftUI

/// SCREEN 3. Builds its layout from the view model's fields; tapping the address pushes the weather route.
struct UserDetailView: View {
    @State private var viewModel: UserDetailViewModel

    init(viewModel: UserDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    AvatarView(data: viewModel.avatarData, isLoading: viewModel.isLoadingAvatar)
                    Text(viewModel.name).font(.title2.bold()).multilineTextAlignment(.center)
                }

                VStack(spacing: 8) {
                    ForEach(viewModel.fields, id: \.title) { field in
                        DetailRow(title: field.title, value: field.value)
                    }
                    NavigationLink(value: Route.weather(viewModel.user)) {
                        DetailRow(title: "Address", value: viewModel.addressText, hint: "Weather")
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Shows the weather at this address")
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await viewModel.toggleFavoriteTapped() }
                } label: {
                    Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                        .foregroundStyle(viewModel.isFavorite ? Color.yellow : Color.accentColor)
                }
                .accessibilityLabel(viewModel.isFavorite ? "Remove from favourites" : "Add to favourites")
            }
        }
        .task { await viewModel.observeFavoriteChanges() }
        .task { await viewModel.loadAvatarIfNeeded() }
    }
}
