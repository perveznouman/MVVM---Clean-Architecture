import SwiftUI

/// Renders a ready-made row; it does no formatting of its own.
struct UserRowView: View {
    let row: UserRowViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Text(row.name).font(.headline)
                if row.isFavorite {
                    Image(systemName: "star.fill").foregroundStyle(.yellow)
                        .accessibilityLabel("Favourite")
                }
            }
            Text(row.username).font(.subheadline).foregroundStyle(.secondary)
            Text(row.email).font(.footnote).foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}
