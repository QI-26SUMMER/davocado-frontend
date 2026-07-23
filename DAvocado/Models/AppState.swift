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
            await APIClient.shared.clearToken()
        }
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
        await APIClient.shared.clearToken()
        currentUser = nil
        scans = []
        stats = nil
        lastScan = nil
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
            scanErrorMessage = error.localizedDescription
        }
    }

    func loadStats() async {
        do {
            stats = try await ScanAPI.stats()
        } catch {
            scanErrorMessage = error.localizedDescription
        }
    }

    func submitScan(imageData: Data, source: PhotoSourceKind, tempCelsius: Double? = nil) async -> Bool {
        scanErrorMessage = nil
        do {
            let result = try await ScanAPI.create(imageData: imageData, source: source, tempCelsius: tempCelsius)
            lastScan = result
            async let history: Void = loadHistory()
            async let statsLoad: Void = loadStats()
            _ = await (history, statsLoad)
            return true
        } catch {
            scanErrorMessage = error.localizedDescription
            return false
        }
    }

    // NOTE: no notification-toggle call here — the backend doesn't expose that endpoint yet
    // (see ScanAPI.swift). The History bell is display-only until it does.
}
