import SwiftUI
import UIKit

/// Shows image bytes from the view model (which stays UIKit-free) or a placeholder while loading.
struct AvatarView: View {
    let data: Data?
    let isLoading: Bool

    var body: some View {
        Group {
            if let data, let image = UIImage(data: data) {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable().scaledToFit().foregroundStyle(.tertiary)
            }
        }
        .frame(width: 120, height: 120)
        .background(Color(.tertiarySystemFill))
        .clipShape(Circle())
        .overlay { if isLoading { ProgressView() } }
        .accessibilityHidden(true)
    }
}
