import Foundation

struct NotificationPayload: Decodable {
    let title: String?
    let body: String?
}

struct NotificationItem: Decodable, Identifiable {
    let id: Int
    let scanId: Int
    let scheduledAt: Date
    let sentAt: Date?
    let status: String // "scheduled" | "sent"
    let payload: NotificationPayload?
}

struct NotificationListResponse: Decodable {
    let items: [NotificationItem]
    let nextCursor: String?
}

enum NotificationStatusFilter: String {
    case scheduled
    case sent
}

enum NotificationAPI {
    static func list(status: NotificationStatusFilter? = nil, limit: Int = 20) async throws -> NotificationListResponse {
        var path = "/notifications?limit=\(limit)"
        if let status { path += "&status=\(status.rawValue)" }
        return try await APIClient.shared.send(path)
    }
}
