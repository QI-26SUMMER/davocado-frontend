import Foundation

struct UserMeResponse: Decodable {
    let id: Int
    let email: String
    let nickname: String?
    let preferredStage: Int
    let pushEnabled: Bool
    let advanceNoticeDays: Int
    let createdAt: Date
}

struct SettingsUpdateRequest: Encodable {
    var preferredStage: Int?
    var pushEnabled: Bool?
    var advanceNoticeDays: Int?
}

struct UserSettings: Decodable {
    let preferredStage: Int
    let pushEnabled: Bool
    let advanceNoticeDays: Int
}

struct PushTokenRequest: Encodable {
    let pushToken: String
}

struct PushTokenResponse: Decodable {
    let pushTokenRegistered: Bool
}

enum UserAPI {
    static func me() async throws -> UserMeResponse {
        try await APIClient.shared.send("/users/me")
    }

    static func updateSettings(
        preferredStage: Int? = nil,
        pushEnabled: Bool? = nil,
        advanceNoticeDays: Int? = nil
    ) async throws -> UserSettings {
        try await APIClient.shared.send(
            "/users/me/settings",
            method: "PATCH",
            body: SettingsUpdateRequest(
                preferredStage: preferredStage,
                pushEnabled: pushEnabled,
                advanceNoticeDays: advanceNoticeDays
            )
        )
    }

    static func registerPushToken(_ token: String) async throws -> PushTokenResponse {
        try await APIClient.shared.send(
            "/users/me/push-token",
            method: "PUT",
            body: PushTokenRequest(pushToken: token)
        )
    }
}
