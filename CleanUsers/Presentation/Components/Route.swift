import Domain

/// Every screen that can be pushed onto a NavigationStack. Routes are plain values, so navigation is data.
enum Route: Hashable {
    case detail(User)
    case weather(User)
}
