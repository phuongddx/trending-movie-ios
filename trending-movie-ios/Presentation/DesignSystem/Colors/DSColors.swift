import UIKit
import SwiftUI

struct DSColors {

    // MARK: - Primary Colors
    static let primaryDark = UIColor(red: 31/255.0, green: 29/255.0, blue: 43/255.0, alpha: 1.0) // #1F1D2B
    static let primarySoft = UIColor(red: 37/255.0, green: 40/255.0, blue: 54/255.0, alpha: 1.0) // #252836
    static let blueAccent = UIColor(red: 18/255.0, green: 205/255.0, blue: 217/255.0, alpha: 1.0) // #12CDD9

    // MARK: - Secondary Colors
    static let successGreen = UIColor(red: 34/255.0, green: 176/255.0, blue: 125/255.0, alpha: 1.0) // #22B07D
    static let warningOrange = UIColor(red: 255/255.0, green: 135/255.0, blue: 0/255.0, alpha: 1.0) // #FF8700
    static let errorRed = UIColor(red: 251/255.0, green: 65/255.0, blue: 65/255.0, alpha: 1.0) // #FB4141

    // MARK: - Text Colors
    static let textBlack = UIColor(red: 23/255.0, green: 23/255.0, blue: 37/255.0, alpha: 1.0) // #171725
    static let textDarkGrey = UIColor(red: 105/255.0, green: 105/255.0, blue: 116/255.0, alpha: 1.0) // #696974
    static let textGrey = UIColor(red: 146/255.0, green: 146/255.0, blue: 157/255.0, alpha: 1.0) // #92929D
    static let textWhiteGrey = UIColor(red: 235/255.0, green: 235/255.0, blue: 239/255.0, alpha: 1.0) // #EBEBEF
    static let textWhite = UIColor.white // #FFFFFF
    static let lineDark = UIColor(red: 234/255.0, green: 234/255.0, blue: 234/255.0, alpha: 1.0) // #EAEAEA

    // MARK: - Semantic Colors
    static let background = primaryDark
    static let surface = primarySoft
    static let accent = blueAccent
    static let primaryText = textWhite
    static let secondaryText = textWhiteGrey
    static let tertiaryText = textGrey
    static let disabledText = textDarkGrey
    static let border = lineDark
    static let success = successGreen
    static let warning = warningOrange
    static let error = errorRed

    // MARK: - Status Background Colors
    static let successBackground = UIColor(red: 34/255.0, green: 176/255.0, blue: 125/255.0, alpha: 0.1)
    static let warningBackground = UIColor(red: 255/255.0, green: 135/255.0, blue: 0/255.0, alpha: 0.1)
    static let errorBackground = UIColor(red: 251/255.0, green: 65/255.0, blue: 65/255.0, alpha: 0.1)

    // MARK: - Loading & Skeleton Colors
    static let shimmerBackground = UIColor(red: 1, green: 1, blue: 1, alpha: 0.1)
    static let shimmerHighlight = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
}

// MARK: - SwiftUI Color Extensions
@available(iOS 13.0, *)
extension DSColors {
    static var backgroundSwiftUI: Color { Color(background) }
    static var surfaceSwiftUI: Color { Color(surface) }
    static var accentSwiftUI: Color { Color(accent) }
    static var primaryTextSwiftUI: Color { Color(primaryText) }
    static var secondaryTextSwiftUI: Color { Color(secondaryText) }
    static var tertiaryTextSwiftUI: Color { Color(tertiaryText) }
    static var disabledTextSwiftUI: Color { Color(disabledText) }
    static var borderSwiftUI: Color { Color(border) }
    static var successSwiftUI: Color { Color(success) }
    static var warningSwiftUI: Color { Color(warning) }
    static var errorSwiftUI: Color { Color(error) }
    static var successBackgroundSwiftUI: Color { Color(successBackground) }
    static var warningBackgroundSwiftUI: Color { Color(warningBackground) }
    static var errorBackgroundSwiftUI: Color { Color(errorBackground) }
    static var shimmerBackgroundSwiftUI: Color { Color(shimmerBackground) }
    static var shimmerHighlightSwiftUI: Color { Color(shimmerHighlight) }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - UIColor Extensions
extension UIColor {
    var swiftUIColor: Color {
        return Color(self)
    }
}