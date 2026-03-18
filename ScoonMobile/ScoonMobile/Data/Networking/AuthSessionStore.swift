import Foundation
import Security

actor AuthSessionStore {
    private static let accessTokenKey  = "scoon.access_token"
    private static let refreshTokenKey = "scoon.refresh_token"
    private static let userIDKey       = "scoon.user_id"

    private(set) var accessToken:  String?
    private(set) var refreshToken: String?
    private(set) var currentUserID: UUID?

    init() {
        accessToken    = Self.load(key: Self.accessTokenKey)
        refreshToken   = Self.load(key: Self.refreshTokenKey)
        currentUserID  = Self.load(key: Self.userIDKey).flatMap(UUID.init(uuidString:))
    }

    func setSession(accessToken: String, refreshToken: String, userID: UUID) {
        self.accessToken   = accessToken
        self.refreshToken  = refreshToken
        self.currentUserID = userID
        Self.save(key: Self.accessTokenKey,  value: accessToken)
        Self.save(key: Self.refreshTokenKey, value: refreshToken)
        Self.save(key: Self.userIDKey,       value: userID.uuidString)
    }

    func clear() {
        accessToken    = nil
        refreshToken   = nil
        currentUserID  = nil
        Self.delete(key: Self.accessTokenKey)
        Self.delete(key: Self.refreshTokenKey)
        Self.delete(key: Self.userIDKey)
    }

    // MARK: – Keychain

    private static func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData:   data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private static func load(key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData:  true,
            kSecMatchLimit:  kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func delete(key: String) {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
