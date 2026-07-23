import Foundation

/// Mirrors the backend's `ErrorCode` enum (see D-avocado API spec §0).
enum APIErrorCode: String, Decodable {
    case badRequest = "BAD_REQUEST"
    case unauthorized = "UNAUTHORIZED"
    case tokenExpired = "TOKEN_EXPIRED"
    case invalidCredentials = "INVALID_CREDENTIALS"
    case forbidden = "FORBIDDEN"
    case notFound = "NOT_FOUND"
    case duplicateEmail = "DUPLICATE_EMAIL"
    case fileTooLarge = "FILE_TOO_LARGE"
    case validationFailed = "VALIDATION_FAILED"
    case noAvocadoDetected = "NO_AVOCADO_DETECTED"
    case inferenceServiceUnavailable = "INFERENCE_SERVICE_UNAVAILABLE"
    case internalError = "INTERNAL_ERROR"
}

private struct APIErrorEnvelope: Decodable {
    struct Detail: Decodable {
        let code: String
        let message: String
    }
    let error: Detail
}

enum APIError: Error, LocalizedError {
    case server(code: APIErrorCode?, rawCode: String, message: String)
    case transport(Error)
    case decoding(Error)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .server(_, _, let message): return message
        case .transport(let error): return error.localizedDescription
        case .decoding: return "Couldn't read the server's response."
        case .invalidResponse: return "The server returned an unexpected response."
        }
    }

    static func from(data: Data, statusCode: Int) -> APIError {
        guard let envelope = try? JSONDecoder().decode(APIErrorEnvelope.self, from: data) else {
            return .server(code: nil, rawCode: "HTTP_\(statusCode)", message: "Request failed (\(statusCode)).")
        }
        return .server(
            code: APIErrorCode(rawValue: envelope.error.code),
            rawCode: envelope.error.code,
            message: envelope.error.message
        )
    }
}
