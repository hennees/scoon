import Foundation

enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"
}

struct APIRequest {
    let method:       HTTPMethod
    let path:         String
    var queryItems:   [URLQueryItem] = []
    var body:         Data?          = nil
    var headers:      [String: String] = [:]
    var requiresAuth: Bool           = false
    /// Supabase PostgREST: prefer=return=representation for INSERT/PATCH
    var preferRepresentation: Bool   = false
}

protocol APIClientProtocol {
    func send<T: Decodable>(_ request: APIRequest, as type: T.Type) async throws -> T
    func send(_ request: APIRequest) async throws
}

struct EmptyResponse: Decodable {}

final class APIClient: APIClientProtocol {
    private let baseURL:         URL
    private let urlSession:      URLSession
    private let sessionStore:    AuthSessionStore
    private let decoder:         JSONDecoder
    private let supabaseAnonKey: String?

    init(
        baseURL:         URL,
        urlSession:      URLSession      = .shared,
        sessionStore:    AuthSessionStore = AuthSessionStore(),
        supabaseAnonKey: String?         = nil
    ) {
        self.baseURL         = baseURL
        self.urlSession      = urlSession
        self.sessionStore    = sessionStore
        self.supabaseAnonKey = supabaseAnonKey

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    func send<T: Decodable>(_ request: APIRequest, as type: T.Type) async throws -> T {
        let urlRequest = try await makeURLRequest(from: request)
        do {
            let (data, response) = try await urlSession.data(for: urlRequest)
            try validate(response: response)
            do {
                return try decoder.decode(type, from: data)
            } catch {
                throw APIError.decodingFailed
            }
        } catch let error as APIError { throw error
        } catch let error as URLError  { throw APIError.transport(error)
        } catch                        { throw APIError.unknown }
    }

    func send(_ request: APIRequest) async throws {
        let urlRequest = try await makeURLRequest(from: request)
        do {
            let (_, response) = try await urlSession.data(for: urlRequest)
            try validate(response: response)
        } catch let error as APIError { throw error
        } catch let error as URLError  { throw APIError.transport(error)
        } catch                        { throw APIError.unknown }
    }

    // MARK: – Private

    private func makeURLRequest(from request: APIRequest) async throws -> URLRequest {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidBaseURL
        }

        let normalizedPath = request.path.hasPrefix("/") ? request.path : "/\(request.path)"
        let basePath       = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let requestPath    = normalizedPath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        if basePath.isEmpty         { components.path = "/\(requestPath)" }
        else if requestPath.isEmpty { components.path = "/\(basePath)" }
        else                        { components.path = "/\(basePath)/\(requestPath)" }

        components.queryItems = request.queryItems.isEmpty ? nil : request.queryItems

        guard let url = components.url else { throw APIError.invalidRequest }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody   = request.body
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        if request.body != nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        // Supabase requires apikey on every request
        if let key = supabaseAnonKey {
            urlRequest.setValue(key, forHTTPHeaderField: "apikey")
        }

        if request.requiresAuth, let token = await sessionStore.accessToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Supabase PostgREST: return the created/updated row
        if request.preferRepresentation {
            urlRequest.setValue("return=representation", forHTTPHeaderField: "Prefer")
        }

        request.headers.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        return urlRequest
    }

    private func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }
        switch httpResponse.statusCode {
        case 200...299: return
        case 401: throw APIError.unauthorized
        case 403: throw APIError.forbidden
        case 404: throw APIError.notFound
        case 409: throw APIError.conflict
        case 422: throw APIError.unprocessableEntity
        default:  throw APIError.serverError(statusCode: httpResponse.statusCode)
        }
    }
}

extension Encodable {
    func asJSONData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return try encoder.encode(self)
    }
}
