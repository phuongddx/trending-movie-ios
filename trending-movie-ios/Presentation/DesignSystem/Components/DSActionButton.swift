import SwiftUI

/// Minimum touch target size per Apple HIG
struct TouchTarget {
    static let minimumSize: CGFloat = 44
}

@available(iOS 15.0, *)
struct DSActionButton: View {
    enum Style {
        case primary
        case secondary
        case text
        case destructive
    }

    enum Size {
        case extraLarge
        case large
        case medium
        case small
        case extraSmall

        var padding: EdgeInsets {
            switch self {
            case .extraLarge: return EdgeInsets(top: 18, leading: 24, bottom: 18, trailing: 24)
            case .large: return EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
            case .medium: return EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
            case .small: return EdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24)
            case .extraSmall: return EdgeInsets(top: 4, leading: 24, bottom: 4, trailing: 24)
            }
        }

        var fontSize: CGFloat {
            switch self {
            case .extraLarge: return 18
            case .large: return 16
            case .medium: return 16
            case .small: return 14
            case .extraSmall: return 12
            }
        }
    }

    let title: String
    let style: Style
    let size: Size
    let icon: CinemaxIcon?
    let isDisabled: Bool
    let action: () -> Void

    @State private var isPressed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        title: String,
        style: Style = .primary,
        size: Size = .medium,
        icon: CinemaxIcon? = nil,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.icon = icon
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: {
            triggerHapticFeedback()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    CinemaxIconView(icon, size: .small, color: foregroundColor)
                }

                Text(title)
                    .font(.custom("Montserrat-Medium", size: size.fontSize))
            }
            .padding(size.padding)
            .frame(maxWidth: .infinity)
            .frame(minHeight: TouchTarget.minimumSize)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isDisabled ? 0.5 : 1.0)
            .animation(reduceMotion ? .none : .easeInOut(duration: 0.1), value: isPressed)
            .contentShape(Rectangle())
        }
        .disabled(isDisabled)
        .accessibilityLabel(title)
        .accessibilityHint("Double tap to activate")
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: {}
        )
    }

    private func triggerHapticFeedback() {
        guard AppSettings.shared.isHapticEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred(intensity: 0.8)
    }

    private var backgroundColor: Color {
        if isDisabled {
            return DSColors.disabledTextSwiftUI
        }

        switch style {
        case .primary:
            return DSColors.accentSwiftUI
        case .secondary:
            return Color.clear
        case .text:
            return Color.clear
        case .destructive:
            return DSColors.errorSwiftUI
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return DSColors.backgroundSwiftUI
        case .secondary, .text:
            return DSColors.accentSwiftUI
        case .destructive:
            return DSColors.primaryTextSwiftUI
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary, .text, .destructive:
            return Color.clear
        case .secondary:
            return DSColors.accentSwiftUI
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .primary, .text, .destructive:
            return 0
        case .secondary:
            return 1
        }
    }
}

@available(iOS 15.0, *)
struct DSIconButton: View {
    let icon: CinemaxIcon
    let style: DSActionButton.Style
    let size: DSIconSize
    let isDisabled: Bool
    let accessibilityLabel: String?
    let action: () -> Void

    @State private var isPressed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        icon: CinemaxIcon,
        style: DSActionButton.Style = .secondary,
        size: DSIconSize = .medium,
        isDisabled: Bool = false,
        accessibilityLabel: String? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.style = style
        self.size = size
        self.isDisabled = isDisabled
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    var body: some View {
        Button(action: {
            triggerHapticFeedback()
            action()
        }) {
            CinemaxIconView(icon, size: size, color: foregroundColor)
                .frame(width: visualButtonSize, height: visualButtonSize)
                .frame(minWidth: TouchTarget.minimumSize, minHeight: TouchTarget.minimumSize)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .opacity(isDisabled ? 0.5 : 1.0)
                .animation(reduceMotion ? .none : .easeInOut(duration: 0.1), value: isPressed)
                .contentShape(Rectangle())
        }
        .disabled(isDisabled)
        .accessibilityLabel(accessibilityLabel ?? iconName)
        .accessibilityHint("Double tap to activate")
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: {}
        )
    }

    private func triggerHapticFeedback() {
        guard AppSettings.shared.isHapticEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred(intensity: 0.6)
    }

    /// Visual button size (icon container)
    private var visualButtonSize: CGFloat {
        switch size {
        case .small: return 32
        case .medium: return 44
        case .large: return 56
        case .extraLarge: return 72
        }
    }

    private var cornerRadius: CGFloat {
        switch size {
        case .small: return 8
        case .medium: return 12
        case .large: return 16
        case .extraLarge: return 20
        }
    }

    private var backgroundColor: Color {
        if isDisabled {
            return DSColors.disabledTextSwiftUI
        }

        switch style {
        case .primary:
            return DSColors.accentSwiftUI
        case .secondary:
            return DSColors.surfaceSwiftUI.opacity(0.8)
        case .text:
            return Color.black.opacity(0.3)
        case .destructive:
            return DSColors.errorSwiftUI
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return DSColors.backgroundSwiftUI
        case .secondary, .text:
            return DSColors.primaryTextSwiftUI
        case .destructive:
            return DSColors.primaryTextSwiftUI
        }
    }

    private var borderColor: Color {
        switch style {
        case .primary, .text, .destructive:
            return Color.clear
        case .secondary:
            return DSColors.borderSwiftUI.opacity(0.3)
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .primary, .text, .destructive:
            return 0
        case .secondary:
            return 1
        }
    }

    /// Map icon to readable name for accessibility
    private var iconName: String {
        switch icon {
        case .heart: return "Favorite"
        case .download, .downloadOffline: return "Watchlist"
        case .share: return "Share"
        case .settings: return "Settings"
        case .search: return "Search"
        case .home: return "Home"
        case .person: return "Profile"
        case .notification: return "Notifications"
        case .remove: return "Remove"
        case .pause: return "Play"
        default: return "Button"
        }
    }
}
