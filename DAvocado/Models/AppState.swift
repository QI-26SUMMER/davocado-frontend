import SwiftUI
import Observation

struct CurrentUser {
    let id: Int
    let email: String
    let nickname: String?

    init(_ user: UserSummary) {
        id = user.id
        email = user.email
        nickname = user.nickname
    }

    init(_ user: UserMeResponse) {
        id = user.id
        email = user.email
        nickname = user.nickname
    }
}

@Observable
final class AppState {
    var currentUser: CurrentUser?
    var isLoggedIn: Bool { currentUser != nil }

    var preferredStage = 3
    var pushEnabled = true
    var advanceNoticeDays = 1

    /// Local-only device preference (not part of the backend's user settings) — sent as
    /// `temp_celsius` on each scan upload. Persisted in UserDefaults, not synced to the server.
    var roomTemperatureCelsius: Double = UserDefaults.standard.object(forKey: "roomTemperatureCelsius") as? Double ?? 24 {
        didSet { UserDefaults.standard.set(roomTemperatureCelsius, forKey: "roomTemperatureCelsius") }
    }

    var scans: [ScanListItem] = []
    var stats: ScanStatsResponse?
    var lastScan: ScanResponse?

    var isLoadingHistory = false
    var authErrorMessage: String?
    var scanErrorMessage: String?

    // MARK: - Bootstrap

    /// Called on app launch to restore a session from the Keychain-stored token.
    func bootstrap() async {
        guard await APIClient.shared.isAuthenticated else { return }
        do {
            let me = try await UserAPI.me()
            applyUser(me)
            async let history: Void = loadHistory()
            async let statsLoad: Void = loadStats()
            _ = await (history, statsLoad)
        } catch {
            await forceLocalLogOut()
        }
    }

    /// A token can expire (2-week TTL, no refresh — see API spec §0/§06) at any point during a
    /// session, not just at launch. Any call that hits UNAUTHORIZED/TOKEN_EXPIRED should drop the
    /// session so the user lands back on the login screen instead of a silently-broken app.
    @discardableResult
    private func handleIfSessionExpired(_ error: Error) async -> Bool {
        guard case let APIError.server(code, _, _) = error,
              code == .unauthorized || code == .tokenExpired else { return false }
        await forceLocalLogOut()
        return true
    }

    private func forceLocalLogOut() async {
        await APIClient.shared.clearToken()
        currentUser = nil
        scans = []
        stats = nil
        lastScan = nil
    }

    // MARK: - Auth

    func signUp(email: String, password: String, nickname: String) async -> Bool {
        authErrorMessage = nil
        do {
            _ = try await AuthAPI.signup(email: email, password: password, nickname: nickname.isEmpty ? nil : nickname)
            return true
        } catch {
            authErrorMessage = error.localizedDescription
            return false
        }
    }

    func logIn(email: String, password: String) async -> Bool {
        authErrorMessage = nil
        do {
            let response = try await AuthAPI.login(email: email, password: password)
            applyUser(response.user)
            async let history: Void = loadHistory()
            async let statsLoad: Void = loadStats()
            _ = await (history, statsLoad)
            return true
        } catch {
            authErrorMessage = error.localizedDescription
            return false
        }
    }

    func logOut() async {
        try? await AuthAPI.logout()
        await forceLocalLogOut()
    }

    private func applyUser(_ user: UserSummary) {
        currentUser = CurrentUser(user)
        preferredStage = user.preferredStage
        pushEnabled = user.pushEnabled
        advanceNoticeDays = user.advanceNoticeDays
    }

    private func applyUser(_ user: UserMeResponse) {
        currentUser = CurrentUser(user)
        preferredStage = user.preferredStage
        pushEnabled = user.pushEnabled
        advanceNoticeDays = user.advanceNoticeDays
    }

    // MARK: - Settings

    func updateSettings(preferredStage: Int? = nil, pushEnabled: Bool? = nil, advanceNoticeDays: Int? = nil) async {
        // Optimistic local update.
        if let preferredStage { self.preferredStage = preferredStage }
        if let pushEnabled { self.pushEnabled = pushEnabled }
        if let advanceNoticeDays { self.advanceNoticeDays = advanceNoticeDays }

        do {
            let updated = try await UserAPI.updateSettings(
                preferredStage: preferredStage,
                pushEnabled: pushEnabled,
                advanceNoticeDays: advanceNoticeDays
            )
            self.preferredStage = updated.preferredStage
            self.pushEnabled = updated.pushEnabled
            self.advanceNoticeDays = updated.advanceNoticeDays
        } catch {
            if await handleIfSessionExpired(error) { return }
            authErrorMessage = error.localizedDescription
        }
    }

    func registerPushToken(_ token: String) async {
        _ = try? await UserAPI.registerPushToken(token)
    }

    // MARK: - Scans

    func loadHistory() async {
        isLoadingHistory = true
        defer { isLoadingHistory = false }
        do {
            let response = try await ScanAPI.list()
            scans = response.items
        } catch {
            if await handleIfSessionExpired(error) { return }
            scanErrorMessage = error.localizedDescription
        }
    }

    func loadStats() async {
        do {
            stats = try await ScanAPI.stats()
        } catch {
            if await handleIfSessionExpired(error) { return }
            scanErrorMessage = error.localizedDescription
        }
    }

    func submitScan(imageData: Data, source: PhotoSourceKind, tempCelsius: Double? = nil) async -> Bool {
        scanErrorMessage = nil
        do {
            let result = try await ScanAPI.create(imageData: imageData, source: source, tempCelsius: tempCelsius)
            print("""
                🥑 SCAN #\(result.id): predicted_stage=\(result.predictedStage) target_stage=\(result.targetStage) \
                temp_celsius=\(tempCelsius ?? -1) days_to_target=\(result.daysToTarget ?? -1) \
                dday_text=\(result.display?.ddayText ?? "nil") status=\(result.display?.status ?? "nil")
                """)
            lastScan = result
            async let history: Void = loadHistory()
            async let statsLoad: Void = loadStats()
            _ = await (history, statsLoad)
            return true
        } catch {
            if await handleIfSessionExpired(error) { return false }
            scanErrorMessage = error.localizedDescription
            return false
        }
    }

    // NOTE: no notification-toggle call here — the backend doesn't expose that endpoint yet
    // (see ScanAPI.swift). The History bell is display-only until it does.

    /// `GET /scans/{id}` — re-fetches full scan detail so a History row can reconstruct the
    /// Result screen (API spec §04: "Result 화면 재구성").
    func loadScanDetail(id: Int) async -> ScanResponse? {
        do {
            let result = try await ScanAPI.get(id: id)
            print("""
                🥑 SCAN #\(result.id) DETAIL: predicted_stage=\(result.predictedStage) \
                days_to_target=\(result.daysToTarget ?? -1) dday_text=\(result.display?.ddayText ?? "nil")
                """)
            return result
        } catch {
            if await handleIfSessionExpired(error) { return nil }
            scanErrorMessage = error.localizedDescription
            return nil
        }
    }
}
