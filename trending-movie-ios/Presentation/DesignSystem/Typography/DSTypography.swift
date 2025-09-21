import UIKit
import SwiftUI

struct DSTypography {

    // MARK: - Font Weights
    enum Weight {
        case regular
        case medium
        case semibold
        case bold

        var uiKitWeight: UIFont.Weight {
            switch self {
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            }
        }

        @available(iOS 13.0, *)
        var swiftUIWeight: Font.Weight {
            switch self {
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            }
        }
    }

    // MARK: - Typography Styles
    static func largeTitle(weight: Weight = .bold) -> UIFont {
        return UIFont.systemFont(ofSize: 34, weight: weight.uiKitWeight)
    }

    static func title1(weight: Weight = .bold) -> UIFont {
        return UIFont.systemFont(ofSize: 28, weight: weight.uiKitWeight)
    }

    static func title2(weight: Weight = .bold) -> UIFont {
        return UIFont.systemFont(ofSize: 22, weight: weight.uiKitWeight)
    }

    static func title3(weight: Weight = .semibold) -> UIFont {
        return UIFont.systemFont(ofSize: 20, weight: weight.uiKitWeight)
    }

    static func headline(weight: Weight = .semibold) -> UIFont {
        return UIFont.systemFont(ofSize: 17, weight: weight.uiKitWeight)
    }

    static func body(weight: Weight = .regular) -> UIFont {
        return UIFont.systemFont(ofSize: 17, weight: weight.uiKitWeight)
    }

    static func callout(weight: Weight = .regular) -> UIFont {
        return UIFont.systemFont(ofSize: 16, weight: weight.uiKitWeight)
    }

    static func subheadline(weight: Weight = .regular) -> UIFont {
        return UIFont.systemFont(ofSize: 15, weight: weight.uiKitWeight)
    }

    static func footnote(weight: Weight = .regular) -> UIFont {
        return UIFont.systemFont(ofSize: 13, weight: weight.uiKitWeight)
    }

    static func caption1(weight: Weight = .regular) -> UIFont {
        return UIFont.systemFont(ofSize: 12, weight: weight.uiKitWeight)
    }

    static func caption2(weight: Weight = .regular) -> UIFont {
        return UIFont.systemFont(ofSize: 11, weight: weight.uiKitWeight)
    }
}

// MARK: - SwiftUI Font Extensions
@available(iOS 13.0, *)
extension DSTypography {
    static func largeTitleSwiftUI(weight: Weight = .bold) -> Font {
        return .system(size: 34, weight: weight.swiftUIWeight)
    }

    static func title1SwiftUI(weight: Weight = .bold) -> Font {
        return .system(size: 28, weight: weight.swiftUIWeight)
    }

    static func title2SwiftUI(weight: Weight = .bold) -> Font {
        return .system(size: 22, weight: weight.swiftUIWeight)
    }

    static func title3SwiftUI(weight: Weight = .semibold) -> Font {
        return .system(size: 20, weight: weight.swiftUIWeight)
    }

    static func headlineSwiftUI(weight: Weight = .semibold) -> Font {
        return .system(size: 17, weight: weight.swiftUIWeight)
    }

    static func bodySwiftUI(weight: Weight = .regular) -> Font {
        return .system(size: 17, weight: weight.swiftUIWeight)
    }

    static func calloutSwiftUI(weight: Weight = .regular) -> Font {
        return .system(size: 16, weight: weight.swiftUIWeight)
    }

    static func subheadlineSwiftUI(weight: Weight = .regular) -> Font {
        return .system(size: 15, weight: weight.swiftUIWeight)
    }

    static func footnoteSwiftUI(weight: Weight = .regular) -> Font {
        return .system(size: 13, weight: weight.swiftUIWeight)
    }

    static func caption1SwiftUI(weight: Weight = .regular) -> Font {
        return .system(size: 12, weight: weight.swiftUIWeight)
    }

    static func caption2SwiftUI(weight: Weight = .regular) -> Font {
        return .system(size: 11, weight: weight.swiftUIWeight)
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
    static func movieTitle(theme: DSTheme = .dark) -> DSTextStyle {
        return DSTextStyle(
            font: DSTypography.title2(),
            color: DSColors.primaryText(for: theme),
            lineHeight: 28
        )
    }

    static func movieSubtitle(theme: DSTheme = .dark) -> DSTextStyle {
        return DSTextStyle(
            font: DSTypography.subheadline(),
            color: DSColors.secondaryText(for: theme),
            lineHeight: 20
        )
    }

    static func bodyText(theme: DSTheme = .dark) -> DSTextStyle {
        return DSTextStyle(
            font: DSTypography.body(),
            color: DSColors.primaryText(for: theme),
            lineHeight: 24
        )
    }

    static func captionText(theme: DSTheme = .dark) -> DSTextStyle {
        return DSTextStyle(
            font: DSTypography.caption1(),
            color: DSColors.secondaryText(for: theme),
            lineHeight: 16
        )
    }
}

// MARK: - UILabel Extension
extension UILabel {
    func applyStyle(_ style: DSTextStyle, text: String) {
        self.attributedText = style.attributedString(from: text)
    }

    func applyMovieTitleStyle(_ text: String) {
        applyStyle(.movieTitle(theme: DSThemeManager.shared.currentTheme), text: text)
    }

    func applyMovieSubtitleStyle(_ text: String) {
        applyStyle(.movieSubtitle(theme: DSThemeManager.shared.currentTheme), text: text)
    }

    func applyBodyTextStyle(_ text: String) {
        applyStyle(.bodyText(theme: DSThemeManager.shared.currentTheme), text: text)
    }

    func applyCaptionTextStyle(_ text: String) {
        applyStyle(.captionText(theme: DSThemeManager.shared.currentTheme), text: text)
    }
}