import UIKit
import SwiftUI

struct DSSpacing {

    // MARK: - Base Spacing Units (8pt grid system)
    static let unit: CGFloat = 8.0

    static let xxxs: CGFloat = unit * 0.25  // 2pt
    static let xxs: CGFloat = unit * 0.5    // 4pt
    static let xs: CGFloat = unit * 0.75    // 6pt
    static let sm: CGFloat = unit           // 8pt
    static let md: CGFloat = unit * 1.5     // 12pt
    static let lg: CGFloat = unit * 2       // 16pt
    static let xl: CGFloat = unit * 2.5     // 20pt
    static let xxl: CGFloat = unit * 3      // 24pt
    static let xxxl: CGFloat = unit * 4     // 32pt
    static let xxxxl: CGFloat = unit * 5    // 40pt

    // MARK: - Component Specific Spacing
    struct Padding {
        static let container: CGFloat = lg           // 16pt
        static let card: CGFloat = md               // 12pt
        static let button: CGFloat = sm             // 8pt
        static let cell: CGFloat = lg               // 16pt
    }

    struct Margin {
        static let section: CGFloat = xxl           // 24pt
        static let item: CGFloat = lg               // 16pt
        static let text: CGFloat = md               // 12pt
    }

    struct Height {
        static let button: CGFloat = unit * 6       // 48pt
        static let cell: CGFloat = unit * 10        // 80pt
        static let header: CGFloat = unit * 7       // 56pt
        static let separator: CGFloat = 1           // 1pt
        static let loadingSpinner: CGFloat = unit * 2.75  // 22pt
    }

    struct CornerRadius {
        static let small: CGFloat = xxs             // 4pt
        static let medium: CGFloat = sm             // 8pt
        static let large: CGFloat = md              // 12pt
        static let card: CGFloat = lg               // 16pt
    }

    // MARK: - Layout Constraints
    struct Layout {
        static let maxContentWidth: CGFloat = 800
        static let minTouchTarget: CGFloat = unit * 5.5  // 44pt
    }
}

// MARK: - SwiftUI Extensions
@available(iOS 13.0, *)
extension DSSpacing {
    struct SwiftUI {
        static let xxxs: CGFloat = DSSpacing.xxxs
        static let xxs: CGFloat = DSSpacing.xxs
        static let xs: CGFloat = DSSpacing.xs
        static let sm: CGFloat = DSSpacing.sm
        static let md: CGFloat = DSSpacing.md
        static let lg: CGFloat = DSSpacing.lg
        static let xl: CGFloat = DSSpacing.xl
        static let xxl: CGFloat = DSSpacing.xxl
        static let xxxl: CGFloat = DSSpacing.xxxl
        static let xxxxl: CGFloat = DSSpacing.xxxxl
    }
}

// MARK: - UIView Extensions
extension UIView {
    func applyContainerPadding() {
        self.layoutMargins = UIEdgeInsets(
            top: DSSpacing.Padding.container,
            left: DSSpacing.Padding.container,
            bottom: DSSpacing.Padding.container,
            right: DSSpacing.Padding.container
        )
    }

    func applyCardPadding() {
        self.layoutMargins = UIEdgeInsets(
            top: DSSpacing.Padding.card,
            left: DSSpacing.Padding.card,
            bottom: DSSpacing.Padding.card,
            right: DSSpacing.Padding.card
        )
    }

    func applyCardStyling() {
        self.layer.cornerRadius = DSSpacing.CornerRadius.card
        self.backgroundColor = DSColors.surface
        applyCardPadding()
    }

    func applyButtonStyling() {
        self.layer.cornerRadius = DSSpacing.CornerRadius.medium
        self.backgroundColor = DSColors.accent

        // Ensure minimum touch target
        if frame.height < DSSpacing.Layout.minTouchTarget {
            frame.size.height = DSSpacing.Layout.minTouchTarget
        }
    }
}

// MARK: - NSLayoutConstraint Extensions
extension NSLayoutConstraint {
    static func createSpacing(_ spacing: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        constraint.constant = spacing
        return constraint
    }

    func applySpacing(_ spacing: CGFloat) {
        self.constant = spacing
    }
}

// MARK: - UIEdgeInsets Extensions
extension UIEdgeInsets {
    static var containerPadding: UIEdgeInsets {
        return UIEdgeInsets(
            top: DSSpacing.Padding.container,
            left: DSSpacing.Padding.container,
            bottom: DSSpacing.Padding.container,
            right: DSSpacing.Padding.container
        )
    }

    static var cardPadding: UIEdgeInsets {
        return UIEdgeInsets(
            top: DSSpacing.Padding.card,
            left: DSSpacing.Padding.card,
            bottom: DSSpacing.Padding.card,
            right: DSSpacing.Padding.card
        )
    }

    static func custom(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> UIEdgeInsets {
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }

    static func uniform(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: value, left: value, bottom: value, right: value)
    }

    static func horizontal(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: value, bottom: 0, right: value)
    }

    static func vertical(_ value: CGFloat) -> UIEdgeInsets {
        return UIEdgeInsets(top: value, left: 0, bottom: value, right: 0)
    }
}