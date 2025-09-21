import UIKit
import SwiftUI

struct DSTypography {

    // MARK: - Font Weights
    enum Weight {
        case regular
        case medium
        case semibold

        var montserratName: String {
            switch self {
            case .regular: return "Montserrat-Regular"
            case .medium: return "Montserrat-Medium"
            case .semibold: return "Montserrat-SemiBold"
            }
        }

        @available(iOS 13.0, *)
        var swiftUIWeight: Font.Weight {
            switch self {
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            }
        }
    }

    // MARK: - Montserrat Font Helper
    private static func montserratFont(size: CGFloat, weight: Weight) -> UIFont {
        if let customFont = UIFont(name: weight.montserratName, size: size) {
            return customFont
        }
        // Fallback to system font with equivalent weight
        let systemWeight: UIFont.Weight = {
            switch weight {
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            }
        }()
        return UIFont.systemFont(ofSize: size, weight: systemWeight)
    }

    // MARK: - Cinemax Typography Hierarchy

    // Heading Styles
    static func h1(weight: Weight = .semibold) -> UIFont {
        return montserratFont(size: 28, weight: weight)
    }

    static func h2(weight: Weight = .semibold) -> UIFont {
        return montserratFont(size: 24, weight: weight)
    }

    static func h3(weight: Weight = .semibold) -> UIFont {
        return montserratFont(size: 18, weight: weight)
    }

    static func h4(weight: Weight = .semibold) -> UIFont {
        return montserratFont(size: 16, weight: weight)
    }

    static func h5(weight: Weight = .semibold) -> UIFont {
        return montserratFont(size: 14, weight: weight)
    }

    static func h6(weight: Weight = .semibold) -> UIFont {
        return montserratFont(size: 12, weight: weight)
    }

    static func h7(weight: Weight = .semibold) -> UIFont {
        return montserratFont(size: 10, weight: weight)
    }

    // Body Styles
    static func bodyLarge(weight: Weight = .medium) -> UIFont {
        return montserratFont(size: 16, weight: weight)
    }

    static func bodyMedium(weight: Weight = .medium) -> UIFont {
        return montserratFont(size: 14, weight: weight)
    }

    static func bodySmall(weight: Weight = .medium) -> UIFont {
        return montserratFont(size: 12, weight: weight)
    }

    static func caption(weight: Weight = .regular) -> UIFont {
        return montserratFont(size: 10, weight: weight)
    }
}

// MARK: - SwiftUI Font Extensions
@available(iOS 13.0, *)
extension DSTypography {

    private static func montserratSwiftUI(size: CGFloat, weight: Weight) -> Font {
        if let _ = UIFont(name: weight.montserratName, size: size) {
            return .custom(weight.montserratName, size: size)
        }
        // Fallback to system font
        return .system(size: size, weight: weight.swiftUIWeight)
    }

    // Heading Styles SwiftUI
    static func h1SwiftUI(weight: Weight = .semibold) -> Font {
        return montserratSwiftUI(size: 28, weight: weight)
    }

    static func h2SwiftUI(weight: Weight = .semibold) -> Font {
        return montserratSwiftUI(size: 24, weight: weight)
    }

    static func h3SwiftUI(weight: Weight = .semibold) -> Font {
        return montserratSwiftUI(size: 18, weight: weight)
    }

    static func h4SwiftUI(weight: Weight = .semibold) -> Font {
        return montserratSwiftUI(size: 16, weight: weight)
    }

    static func h5SwiftUI(weight: Weight = .semibold) -> Font {
        return montserratSwiftUI(size: 14, weight: weight)
    }

    static func h6SwiftUI(weight: Weight = .semibold) -> Font {
        return montserratSwiftUI(size: 12, weight: weight)
    }

    static func h7SwiftUI(weight: Weight = .semibold) -> Font {
        return montserratSwiftUI(size: 10, weight: weight)
    }

    // Body Styles SwiftUI
    static func bodyLargeSwiftUI(weight: Weight = .medium) -> Font {
        return montserratSwiftUI(size: 16, weight: weight)
    }

    static func bodyMediumSwiftUI(weight: Weight = .medium) -> Font {
        return montserratSwiftUI(size: 14, weight: weight)
    }

    static func bodySmallSwiftUI(weight: Weight = .medium) -> Font {
        return montserratSwiftUI(size: 12, weight: weight)
    }

    static func captionSwiftUI(weight: Weight = .regular) -> Font {
        return montserratSwiftUI(size: 10, weight: weight)
    }
}

// MARK: - Text Style Helpers
struct DSTextStyle {
    let font: UIFont
    let color: UIColor
    let lineHeight: CGFloat?

    init(font: UIFont, color: UIColor, lineHeight: CGFloat? = nil) {
        self.font = font
        self.color = color
        self.lineHeight = lineHeight
    }

    func attributedString(from text: String) -> NSAttributedString {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]

        if let lineHeight = lineHeight {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineHeight - font.lineHeight
            attributes[.paragraphStyle] = paragraphStyle
        }

        return NSAttributedString(string: text, attributes: attributes)
    }
}

// MARK: - Predefined Text Styles
extension DSTextStyle {
    static func movieTitle() -> DSTextStyle {
        return DSTextStyle(
            font: DSTypography.h2(),
            color: DSColors.primaryText,
            lineHeight: 28
        )
    }

    static func movieSubtitle() -> DSTextStyle {
        return DSTextStyle(
            font: DSTypography.bodyMedium(),
            color: DSColors.secondaryText,
            lineHeight: 20
        )
    }

    static func bodyText() -> DSTextStyle {
        return DSTextStyle(
            font: DSTypography.bodyMedium(),
            color: DSColors.primaryText,
            lineHeight: 24
        )
    }

    static func captionText() -> DSTextStyle {
        return DSTextStyle(
            font: DSTypography.caption(),
            color: DSColors.secondaryText,
            lineHeight: 16
        )
    }

    static func heroTitle() -> DSTextStyle {
        return DSTextStyle(
            font: DSTypography.h1(),
            color: DSColors.primaryText,
            lineHeight: 34
        )
    }

    static func sectionHeader() -> DSTextStyle {
        return DSTextStyle(
            font: DSTypography.h3(),
            color: DSColors.primaryText,
            lineHeight: 22
        )
    }
}

// MARK: - UILabel Extension
extension UILabel {
    func applyStyle(_ style: DSTextStyle, text: String) {
        self.attributedText = style.attributedString(from: text)
    }

    func applyMovieTitleStyle(_ text: String) {
        applyStyle(.movieTitle(), text: text)
    }

    func applyMovieSubtitleStyle(_ text: String) {
        applyStyle(.movieSubtitle(), text: text)
    }

    func applyBodyTextStyle(_ text: String) {
        applyStyle(.bodyText(), text: text)
    }

    func applyCaptionTextStyle(_ text: String) {
        applyStyle(.captionText(), text: text)
    }

    func applyHeroTitleStyle(_ text: String) {
        applyStyle(.heroTitle(), text: text)
    }

    func applySectionHeaderStyle(_ text: String) {
        applyStyle(.sectionHeader(), text: text)
    }
}