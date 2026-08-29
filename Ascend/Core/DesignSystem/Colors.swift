import SwiftUI

/// Ascend's palette. Dark mode is the primary design target; light mode values
/// are tuned separately rather than derived, per Apple HIG guidance.
/// Backing colors live in Assets.xcassets as color sets named identically so
/// they participate in system appearance switching automatically; the values
/// below are the source of truth used to generate/verify those sets.
enum AscendColor {
    /// Deep charcoal background (dark) / soft off-white (light).
    static let background = Color("AscendBackground", bundle: .main)
    /// Slightly elevated surface for cards.
    static let surface = Color("AscendSurface", bundle: .main)
    /// Secondary elevated surface (nested cards, list rows).
    static let surfaceSecondary = Color("AscendSurfaceSecondary", bundle: .main)
    /// Primary brand accent — used for progress rings, CTAs, selected states.
    static let accent = Color("AscendAccent", bundle: .main)
    /// Secondary accent for variety across widgets (e.g. habits vs workouts).
    static let accentSecondary = Color("AscendAccentSecondary", bundle: .main)
    static let success = Color("AscendSuccess", bundle: .main)
    static let warning = Color("AscendWarning", bundle: .main)
    static let danger = Color("AscendDanger", bundle: .main)
    static let textPrimary = Color("AscendTextPrimary", bundle: .main)
    static let textSecondary = Color("AscendTextSecondary", bundle: .main)
    static let divider = Color("AscendDivider", bundle: .main)

    /// Fallback palette used anywhere Assets.xcassets color sets haven't been created yet
    /// (e.g. SwiftUI previews before the asset catalog is populated). Prefer the named
    /// colors above once AscendAssets are added per README instructions.
    enum Fallback {
        static let accent = Color(red: 0.40, green: 0.85, blue: 0.65)
        static let accentSecondary = Color(red: 0.45, green: 0.60, blue: 0.98)
    }

    /// Parses a habit/goal's stored hex string (e.g. "#6BD9A6") into a Color.
    static func fromHex(_ hex: String) -> Color {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        sanitized = sanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255
        return Color(red: r, green: g, blue: b)
    }

    static let habitPalette: [String] = [
        "#6BD9A6", "#74A8FA", "#F2C55C", "#F27C8D", "#B48DF2", "#5CCDD9", "#F29A5C"
    ]
}
