import Foundation

struct AppEnvironment {
    let apiBaseURL:      URL?
    let supabaseAnonKey: String?
    let useRemoteData:   Bool

    static let current: AppEnvironment = {
        let env   = ProcessInfo.processInfo.environment
        let plist = Bundle.main.infoDictionary ?? [:]

        func resolve(_ key: String) -> String? {
            let fromEnv = env[key]?.trimmingCharacters(in: .whitespacesAndNewlines)
            if let v = fromEnv, !v.isEmpty { return v }
            return plist[key] as? String
        }

        let rawURL    = resolve("SUPABASE_URL")
        let parsedURL = rawURL.flatMap(URL.init(string:))
        let anonKey   = resolve("SUPABASE_ANON_KEY")

        let remoteFlag = parseBool(resolve("SCOON_USE_REMOTE_DATA")) ?? false

        return AppEnvironment(
            apiBaseURL:      parsedURL,
            supabaseAnonKey: anonKey,
            useRemoteData:   remoteFlag && parsedURL != nil && anonKey != nil
        )
    }()

    private static func parseBool(_ raw: String?) -> Bool? {
        guard let raw else { return nil }
        switch raw.lowercased() {
        case "1", "true", "yes", "y", "on":  return true
        case "0", "false", "no", "n", "off": return false
        default: return nil
        }
    }
}
