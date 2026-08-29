import SwiftUI

/// Type scale built on Dynamic Type text styles so the whole app respects
/// accessibility text sizing out of the box.
enum AscendFont {
    static func largeTitle() -> Font { .system(.largeTitle, design: .rounded, weight: .bold) }
    static func title() -> Font { .system(.title2, design: .rounded, weight: .bold) }
    static func headline() -> Font { .system(.headline, design: .rounded, weight: .semibold) }
    static func body() -> Font { .system(.body, design: .default, weight: .regular) }
    static func subheadline() -> Font { .system(.subheadline, design: .default, weight: .medium) }
    static func footnote() -> Font { .system(.footnote, design: .default, weight: .regular) }
    static func caption() -> Font { .system(.caption, design: .default, weight: .medium) }
    /// Large numeric readouts (streaks, scores).
    static func statValue() -> Font { .system(.largeTitle, design: .rounded, weight: .heavy) }
}
