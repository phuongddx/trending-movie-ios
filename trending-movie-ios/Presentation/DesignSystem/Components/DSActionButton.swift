import SwiftUI

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
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    CinemaxIconView(icon, size: .small, color: foregroundColor)
                }

                Text(title)
                    .font(.custom("Montserrat-Medium", size: size.fontSize))
            }
            .padding(size.padding)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isDisabled ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .disabled(isDisabled)
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: {}
        )
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
    let action: () -> Void

    @State private var isPressed = false

    init(
        icon: CinemaxIcon,
        style: DSActionButton.Style = .secondary,
        size: DSIconSize = .medium,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.style = style
        self.size = size
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            CinemaxIconView(icon, size: size, color: foregroundColor)
                .frame(width: buttonSize, height: buttonSize)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .opacity(isDisabled ? 0.5 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .disabled(isDisabled)
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: {}
        )
    }

    private var buttonSize: CGFloat {
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
}