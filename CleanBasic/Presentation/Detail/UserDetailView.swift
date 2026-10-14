import SwiftUI

/// VIEW for the detail screen: avatar, name, all the fields, and a star button in the toolbar.
struct UserDetailView: View {
    @State private var viewModel: UserDetailViewModel

    init(viewModel: UserDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    avatar
                    Text(viewModel.name).font(.title2.bold()).multilineTextAlignment(.center)
                }

                VStack(spacing: 8) {
                    ForEach(viewModel.fields, id: \.title) { field in
                        DetailRow(title: field.title, value: field.value)
                    }
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
    }

    /// `AsyncImage` downloads and shows the picture; we only choose what to show while loading or on failure.
    private var avatar: some View {
        AsyncImage(url: viewModel.avatarURL) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            case .failure:
                Image(systemName: "person.crop.circle.fill").resizable().scaledToFit().foregroundStyle(.tertiary)
            default:
                ProgressView()
            }
        }
        .frame(width: 120, height: 120)
        .background(Color(.tertiarySystemFill))
        .clipShape(Circle())
        .accessibilityHidden(true)
    }
}
