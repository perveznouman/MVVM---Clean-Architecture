import Foundation

enum APIError: LocalizedError {
    case badStatus(Int)
    case decoding(Error)
    case transport(Error)
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .badStatus(let code): return "The server responded with status \(code)."
        case .decoding: return "The server response could not be read."
        case .transport(let error): return error.localizedDescription
        case .invalidURL: return "The request URL was invalid."
        }
    }
}

protocol HTTPClient {
    func data(from url: URL) async throws -> Data
}

extension HTTPClient {
    func get<T: Decodable>(_ type: T.Type, from url: URL) async throws -> T {
        let data = try await data(from: url)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}

struct URLSessionHTTPClient: HTTPClient {
    var session: URLSession = .shared

    func data(from url: URL) async throws -> Data {
        do {
            let (data, response) = try await session.data(from: url)
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                throw APIError.badStatus(http.statusCode)
            }
            return data
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.transport(error)
        }
    }
}
