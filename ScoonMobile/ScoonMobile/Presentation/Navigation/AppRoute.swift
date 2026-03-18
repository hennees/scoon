import Foundation

enum AppRoute: Hashable {
    case welcome
    case signUpSocial        // Sign Up 1 – social options (Google / Apple / Email)
    case signUpForm          // Sign Up 3 – dark form (username / email / password)
    case signUpEmail         // Sign Up 2 – light-card email form
    case login               // Log In 1
    case home
    case placeInfo(Spot)
    case ortAuswahl
    case kartenansicht       // Map view with pins
    case kartenansichtDetail // Map view + bottom sheet with spot cards
    case favorites           // Meine Favoriten / Meine Orte tabs
    case settings            // Settings screen
    case addPhotoSpot        // Add Photo Spot form
    case insights            // Stats / insights dashboard
    case profile             // User profile with photo grid
    case einnahmen           // Earnings overview
    case ortSuche            // City selection sheet
    case transaktionen       // Transactions list
    case privacyPolicy       // Datenschutzerklärung
    case termsOfService      // Nutzungsbedingungen
    case imprint             // Impressum
    case editProfile(User)    // Profil bearbeiten
    case addPhotoToSpot(Spot) // Foto zu bestehendem Spot hinzufügen
    case becomeCreator        // Creator-Bewerbung
}
