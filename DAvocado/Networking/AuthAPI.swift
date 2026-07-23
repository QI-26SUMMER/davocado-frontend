import Foundation

struct SignupRequest: Encodable {
    let email: String
    let password: String
    let nickname: String?
}

struct SignupResponse: Decodable {
    let id: Int
    let email: String
    let nickname: String?
    let createdAt: Date
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct UserSummary: Decodable {
    let id: Int
    let email: String
    let nickname: String?
    let preferredStage: Int
    let pushEnabled: Bool
    let advanceNoticeDays: Int
}

struct LoginResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let user: UserSummary
}

enum AuthAPI {
    static func signup(email: String, password: String, nickname: String?) async throws -> SignupResponse {
        try await APIClient.shared.send(
            "/auth/signup",
            method: "POST",
            body: SignupRequest(email: email, password: password, nickname: nickname),
            auth: false
        )
    }

    static func login(email: String, password: String) async throws -> LoginResponse {
        let response: LoginResponse = try await APIClient.shared.send(
            "/auth/login",
            method: "POST",
            body: LoginRequest(email: email, password: password),
            auth: false
        )
        await APIClient.shared.storeToken(response.accessToken)
        return response
    }

    static func logout() async throws {
        try await APIClient.shared.sendNoContent("/auth/logout", method: "POST")
        await APIClient.shared.clearToken()
    }
}
