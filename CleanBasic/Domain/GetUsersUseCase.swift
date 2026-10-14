import Foundation

/// USE CASE: one thing the app can do. Here it is just "get the users".
/// The view model calls this and never talks to a repository directly.
protocol GetUsersUseCase {
    func execute() async throws -> [User]
}

struct DefaultGetUsersUseCase: GetUsersUseCase {
    private let repository: UserRepository

    init(repository: UserRepository) {
        self.repository = repository
    }

    func execute() async throws -> [User] {
        // Any business rule would go here (sorting, filtering, ...). For now we sort by name.
        try await repository.fetchUsers().sorted { $0.name < $1.name }
    }
}
