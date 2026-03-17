import SwiftUI

/// Named constants for the scoon design system.
/// Replaces magic numbers scattered across all screens.
enum Spacing {
    static let xs:   CGFloat = 4
    static let sm:   CGFloat = 8
    static let md:   CGFloat = 16
    static let lg:   CGFloat = 20
    static let xl:   CGFloat = 24
    static let xxl:  CGFloat = 32

    static let safeTop:       CGFloat = 56   // top padding below status bar
    static let horizontalPad: CGFloat = 20   // standard horizontal screen margin
    static let navBarHeight:  CGFloat = 80   // bottom nav reserve
}

enum FontSize {
    static let logo:     CGFloat = 28
    static let headline: CGFloat = 26
    static let title:    CGFloat = 22
    static let section:  CGFloat = 20
    static let body:     CGFloat = 16
    static let caption:  CGFloat = 14
    static let small:    CGFloat = 12
}
