import Foundation
import Security

protocol TokenStore: Sendable {
    func load() -> String?
    func save(_ token: String)
    func clear()
}

/// Stores the single bearer token (no refresh token, per API spec §1) in the Keychain.
final class KeychainTokenStore: TokenStore {
    private let account = "com.namyujin.DAvocado.accessToken"

    func load() -> String? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    func save(_ token: String) {
        clear()
        var query = baseQuery
        query[kSecValueData as String] = Data(token.utf8)
        SecItemAdd(query as CFDictionary, nil)
    }

    func clear() {
        SecItemDelete(baseQuery as CFDictionary)
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
        ]
    }
}
