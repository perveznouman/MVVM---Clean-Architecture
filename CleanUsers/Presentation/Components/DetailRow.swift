import SwiftUI

struct DetailRow: View {
    let title: String
    let value: String
    var hint: String?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title.uppercased()).font(.caption).foregroundStyle(.secondary)
                Text(value).font(.body).multilineTextAlignment(.leading)
            }
            Spacer()
            if let hint {
                HStack(spacing: 4) {
                    Text(hint)
                    Image(systemName: "chevron.right")
                }
                .font(.footnote)
                .foregroundStyle(.tint)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
    }
}
