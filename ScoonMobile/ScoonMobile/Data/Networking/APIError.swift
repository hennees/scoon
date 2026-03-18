import Foundation

enum APIError: LocalizedError {
    case invalidBaseURL
    case invalidRequest
    case unauthorized
    case forbidden
    case notFound
    case conflict
    case unprocessableEntity
    case serverError(statusCode: Int)
    case decodingFailed
    case transport(URLError)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidBaseURL:
            return "API-Konfiguration fehlt. Bitte Base URL prüfen."
        case .invalidRequest:
            return "Ungültige Anfrage."
        case .unauthorized:
            return "Nicht eingeloggt oder Sitzung abgelaufen."
        case .forbidden:
            return "Keine Berechtigung für diese Aktion."
        case .notFound:
            return "Ressource nicht gefunden."
        case .conflict:
            return "Konflikt bei der Verarbeitung der Anfrage."
        case .unprocessableEntity:
            return "Eingaben konnten nicht verarbeitet werden."
        case .serverError:
            return "Serverfehler. Bitte später erneut versuchen."
        case .decodingFailed:
            return "Antwort konnte nicht gelesen werden."
        case .transport(let error):
            return error.localizedDescription
        case .unknown:
            return "Unbekannter Fehler."
        }
    }
}
