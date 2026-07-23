import Foundation

/// Thin REST client for the D-avocado API (see D-avocado_API_명세서.md v1.0).
/// Handles bearer-token auth, snake_case JSON conversion, the shared
/// `{ "error": { "code", "message" } }` envelope, and multipart image upload.
actor APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let tokenStore: TokenStore
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(session: URLSession = .shared, tokenStore: TokenStore = KeychainTokenStore()) {
        self.session = session
        self.tokenStore = tokenStore

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            if let date = APIClient.iso8601Fractional.date(from: string) { return date }
            if let date = APIClient.iso8601.date(from: string) { return date }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
        }
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder = encoder
    }

    private static let iso8601: ISO8601DateFormatter = ISO8601DateFormatter()
    private static let iso8601Fractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    var isAuthenticated: Bool { tokenStore.load() != nil }

    func storeToken(_ token: String) { tokenStore.save(token) }
    func clearToken() { tokenStore.clear() }

    // MARK: - JSON requests

    /// Every success response from the real backend is wrapped as `{ "data": ... }`
    /// (see `global.common.ApiResponse` in the `davocado-backend` repo).
    private struct Envelope<T: Decodable>: Decodable { let data: T }

    @discardableResult
    func send<Response: Decodable>(
        _ path: String,
        method: String = "GET",
        body: Encodable? = nil,
        auth: Bool = true
    ) async throws -> Response {
        let data = try await sendRaw(path, method: method, body: body, auth: auth)
        do {
            return try decoder.decode(Envelope<Response>.self, from: data).data
        } catch {
            throw APIError.decoding(error)
        }
    }

    /// For endpoints that return 204 No Content.
    func sendNoContent(_ path: String, method: String, body: Encodable? = nil, auth: Bool = true) async throws {
        _ = try await sendRaw(path, method: method, body: body, auth: auth)
    }

    /// `appendingPathComponent` percent-encodes `?`/`&`, breaking query strings — build via
    /// `URL(string:relativeTo:)` instead so paths like `/scans?limit=20&cursor=5` resolve correctly.
    private func url(for path: String) -> URL {
        guard let url = URL(string: path, relativeTo: APIConfig.baseURL) else {
            preconditionFailure("Malformed API path: \(path)")
        }
        return url
    }

    private func sendRaw(_ path: String, method: String, body: Encodable?, auth: Bool) async throws -> Data {
        var request = URLRequest(url: url(for: path))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if auth, let token = tokenStore.load() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }

        let (data, response) = try await perform(request)
        try Self.validate(response: response, data: data)
        return data
    }

    // MARK: - Multipart upload

    func upload<Response: Decodable>(
        _ path: String,
        fileFieldName: String,
        fileData: Data,
        filename: String,
        mimeType: String,
        fields: [String: String]
    ) async throws -> Response {
        var request = URLRequest(url: url(for: path))
        request.httpMethod = "POST"
        if let token = tokenStore.load() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        for (key, value) in fields {
            body.append("--\(boundary)\r\n".utf8Data)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8Data)
            body.append("\(value)\r\n".utf8Data)
        }
        body.append("--\(boundary)\r\n".utf8Data)
        body.append("Content-Disposition: form-data; name=\"\(fileFieldName)\"; filename=\"\(filename)\"\r\n".utf8Data)
        body.append("Content-Type: \(mimeType)\r\n\r\n".utf8Data)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".utf8Data)
        request.httpBody = body

        let (data, response) = try await perform(request)
        try Self.validate(response: response, data: data)
        do {
            return try decoder.decode(Envelope<Response>.self, from: data).data
        } catch {
            throw APIError.decoding(error)
        }
    }

    private func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw APIError.transport(error)
        }
    }

    private static func validate(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else {
            throw APIError.from(data: data, statusCode: http.statusCode)
        }
    }
}

private extension String {
    var utf8Data: Data { Data(utf8) }
}

/// Type-erasing wrapper so `send(_:body:)` can accept any `Encodable` value.
private struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void
    init(_ wrapped: Encodable) {
        encodeClosure = wrapped.encode
    }
    func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}
