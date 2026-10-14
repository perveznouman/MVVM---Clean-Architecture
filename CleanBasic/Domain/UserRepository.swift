import Foundation

/// REPOSITORY PROTOCOL: what the Domain needs from the outside world ("give me users").
/// It only says WHAT. The Data layer decides HOW (network, database, ...).
protocol UserRepository {
    func fetchUsers() async throws -> [User]
}
