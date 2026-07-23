import Foundation

/// `stage_label` is deliberately NOT sent by the backend (see `ScanDisplay.java`'s doc comment) —
/// clients derive it from `predictedStage` via `RipenessStage.label` instead.
struct ScanDisplay: Decodable {
    let ddayText: String
    let status: String // "ripening" | "eat_now" | "overripe"
}

struct ScanImageInfo: Decodable {
    let croppedUrl: String?
}

struct ScanResponse: Decodable, Identifiable {
    let id: Int
    let predictedStage: Int
    let confidence: Double?
    let stageProbs: [Double]?
    let targetStage: Int
    let daysToTarget: Double?
    let estimatedPeakDate: String?
    let modelVersion: String
    let image: ScanImageInfo?
    let createdAt: Date
    let display: ScanDisplay?
}

/// A scan has at most one notification; `status` is `scheduled` / `sent` / `none`.
struct ScanNotificationStatus: Decodable {
    let status: String
}

struct ScanListItem: Decodable, Identifiable {
    let id: Int
    let predictedStage: Int
    let targetStage: Int
    let daysToTarget: Double?
    let estimatedPeakDate: String?
    let createdAt: Date
    let display: ScanDisplay?
    let notification: ScanNotificationStatus
    let thumbnailUrl: String?
}

struct ScanListResponse: Decodable {
    let items: [ScanListItem]
    let nextCursor: Int?
}

struct ScanStatsResponse: Decodable {
    let total: Int
    let notified: Int
    let pending: Int
}

enum PhotoSourceKind: String {
    case camera
    case gallery
}

enum ScanAPI {
    static func create(imageData: Data, source: PhotoSourceKind, tempCelsius: Double?) async throws -> ScanResponse {
        var fields = ["source": source.rawValue]
        if let tempCelsius {
            fields["temp_celsius"] = String(tempCelsius)
        }
        return try await APIClient.shared.upload(
            "/scans",
            fileFieldName: "image",
            fileData: imageData,
            filename: "scan.jpg",
            mimeType: "image/jpeg",
            fields: fields
        )
    }

    static func list(cursor: Int? = nil, limit: Int = 20) async throws -> ScanListResponse {
        var path = "/scans?limit=\(limit)"
        if let cursor { path += "&cursor=\(cursor)" }
        return try await APIClient.shared.send(path)
    }

    static func stats() async throws -> ScanStatsResponse {
        try await APIClient.shared.send("/scans/stats")
    }

    static func get(id: Int) async throws -> ScanResponse {
        try await APIClient.shared.send("/scans/\(id)")
    }

    static func delete(id: Int) async throws {
        try await APIClient.shared.sendNoContent("/scans/\(id)", method: "DELETE")
    }

    // NOTE: the backend's ScanController has no `PATCH /scans/{id}/notification` route yet —
    // the bell toggle in History is display-only until that endpoint ships server-side.
}
