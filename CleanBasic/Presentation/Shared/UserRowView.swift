import SwiftUI

/// One row: the user's details on the left, the favourite (star) button on the right. Used by both tabs.
struct UserRowView: View {
    let row: UserRow
    let onToggleFavorite: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(row.name).font(.headline)
                Text(row.username).font(.subheadline).foregroundStyle(.secondary)
                Text(row.email).font(.footnote).foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: onToggleFavorite) {
                Image(systemName: row.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(row.isFavorite ? Color.yellow : Color.secondary)
                    .imageScale(.large)
            }
            .buttonStyle(.borderless) // so tapping the star does not count as tapping the whole row
            .accessibilityLabel(row.isFavorite ? "Remove from favourites" : "Add to favourites")
        }
        .padding(.vertical, 4)
    }
}
