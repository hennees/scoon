import SwiftUI

extension Color {
    static let scoonOrange = Color(red: 248/255, green: 89/255, blue: 0/255)

    // ── Adaptive backgrounds ──────────────────────────────────────────
    /// Main screen background  (dark: #222222 / light: #F5F5F7)
    static let scoonDarker = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 34/255,  green: 34/255,  blue: 34/255,  alpha: 1)
            : UIColor(red: 245/255, green: 245/255, blue: 247/255, alpha: 1)
    })

    /// Surface / card background  (dark: #2F2F2F / light: #FFFFFF)
    static let scoonDark = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 47/255,  green: 47/255,  blue: 47/255,  alpha: 1)
            : UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    })

    /// Nav bar background  (dark: #0E0F10 / light: #FFFFFF)
    static let scoonNavBar = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 14/255,  green: 15/255,  blue: 16/255,  alpha: 1)
            : UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    })

    // ── Adaptive text ─────────────────────────────────────────────────
    /// Secondary / muted text  (dark: light gray / light: medium gray)
    static let scoonTextSecondary = Color(UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 160/255, green: 158/255, blue: 158/255, alpha: 1)
            : UIColor(red: 100/255, green: 100/255, blue: 104/255, alpha: 1)
    })

    // ── Legacy (kept for any old references) ─────────────────────────
    static let scoonCardLight    = Color(red: 223/255, green: 219/255, blue: 219/255)
    static let scoonBorder       = Color(red: 216/255, green: 218/255, blue: 220/255)
    static let scoonFilterActive = Color(red: 255/255, green: 148/255, blue: 50/255)
    static let scoonFilterBg     = Color(red: 255/255, green: 238/255, blue: 211/255)
    static let scoonFilterBorder = Color(red: 255/255, green: 188/255, blue: 109/255)
    static let scoonActiveText   = Color(red: 70/255,  green: 19/255,  blue: 4/255)
}
