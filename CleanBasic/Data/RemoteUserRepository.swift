import Foundation

/// Implements the Domain's `UserRepository` using the network.
///
struct RemoteUserRepository: UserRepository {
    private let url = URL(string: "https://jsonplaceholder.typicode.com/users")!

    func fetchUsers() async throws -> [User] {
        let (data, _) = try await URLSession.shared.data(from: url)
        let dtos = try JSONDecoder().decode([UserDTO].self, from: data)
        return dtos.map { $0.toDomain() }
    }
}
