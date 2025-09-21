import SwiftUI

@available(iOS 15.0, *)
struct DSActionButton: View {
    enum Style {
        case primary
        case secondary
        case destructive
        case ghost
    }

    let title: String
    let style: Style
    let icon: String?
    let action: () -> Void

    @Environment(\.dsTheme) private var theme
    @State private var isPressed = false

    init(title: String, style: Style = .primary, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(DSTypography.bodySwiftUI(weight: .medium))
                }

                Text(title)
                    .font(DSTypography.bodySwiftUI(weight: .medium))
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(DSSpacing.CornerRadius.medium)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
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
        switch style {
        case .primary:
            return DSColors.accentSwiftUI(for: theme)
        case .secondary:
            return DSColors.secondaryBackgroundSwiftUI(for: theme)
        case .destructive:
            return Color.red
        case .ghost:
            return Color.clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return theme == .dark ? DSColors.primaryBackgroundSwiftUI(for: theme) : Color.white
        case .secondary:
            return DSColors.primaryTextSwiftUI(for: theme)
        case .destructive:
            return Color.white
        case .ghost:
            return DSColors.accentSwiftUI(for: theme)
        }
    }
}

@available(iOS 15.0, *)
struct DSIconButton: View {
    let icon: String
    let style: DSActionButton.Style
    let action: () -> Void

    @Environment(\.dsTheme) private var theme
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(foregroundColor)
                .frame(width: 44, height: 44)
                .background(backgroundColor)
                .cornerRadius(DSSpacing.CornerRadius.medium)
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
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
        switch style {
        case .primary:
            return DSColors.accentSwiftUI(for: theme)
        case .secondary:
            return DSColors.secondaryBackgroundSwiftUI(for: theme).opacity(0.8)
        case .destructive:
            return Color.red
        case .ghost:
            return Color.black.opacity(0.3)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:
            return theme == .dark ? DSColors.primaryBackgroundSwiftUI(for: theme) : Color.white
        case .secondary, .ghost:
            return DSColors.primaryTextSwiftUI(for: theme)
        case .destructive:
            return Color.white
        }
    }
}