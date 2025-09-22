import SwiftUI

@available(iOS 15.0, *)
struct DSCard<Content: View>: View {
    enum Style {
        case elevated
        case outlined
        case filled
    }

    enum Padding {
        case none
        case small
        case medium
        case large
        case custom(CGFloat)

        var value: CGFloat {
            switch self {
            case .none: return 0
            case .small: return DSSpacing.sm
            case .medium: return DSSpacing.md
            case .large: return DSSpacing.lg
            case .custom(let value): return value
            }
        }
    }

    private let content: Content
    private let style: Style
    private let padding: Padding
    private let cornerRadius: CGFloat
    private let action: (() -> Void)?

    init(
        style: Style = .elevated,
        padding: Padding = .medium,
        cornerRadius: CGFloat = DSSpacing.CornerRadius.card,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.action = action
        self.content = content()
    }

    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    cardContent
                }
                .buttonStyle(CardButtonStyle())
            } else {
                cardContent
            }
        }
    }

    private var cardContent: some View {
        content
            .padding(padding.value)
            .background(backgroundView)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: shadowOffset.x,
                y: shadowOffset.y
            )
    }

    // MARK: - Style Properties

    private var backgroundView: some View {
        switch style {
        case .elevated, .outlined:
            return DSColors.surfaceSwiftUI
        case .filled:
            return DSColors.secondaryBackgroundSwiftUI
        }
    }

    private var borderColor: Color {
        switch style {
        case .outlined:
            return DSColors.borderSwiftUI
        case .elevated, .filled:
            return Color.clear
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .outlined:
            return 1
        case .elevated, .filled:
            return 0
        }
    }

    private var shadowColor: Color {
        switch style {
        case .elevated:
            return Color.black.opacity(0.1)
        case .outlined, .filled:
            return Color.clear
        }
    }

    private var shadowRadius: CGFloat {
        switch style {
        case .elevated:
            return 8
        case .outlined, .filled:
            return 0
        }
    }

    private var shadowOffset: CGSize {
        switch style {
        case .elevated:
            return CGSize(width: 0, height: 2)
        case .outlined, .filled:
            return .zero
        }
    }
}

// MARK: - Card Button Style

private struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Convenience Extensions

extension DSCard {
    static func elevated<Content: View>(
        padding: Padding = .medium,
        @ViewBuilder content: @escaping () -> Content
    ) -> DSCard<Content> {
        DSCard(style: .elevated, padding: padding, content: content)
    }

    static func outlined<Content: View>(
        padding: Padding = .medium,
        @ViewBuilder content: @escaping () -> Content
    ) -> DSCard<Content> {
        DSCard(style: .outlined, padding: padding, content: content)
    }

    static func filled<Content: View>(
        padding: Padding = .medium,
        @ViewBuilder content: @escaping () -> Content
    ) -> DSCard<Content> {
        DSCard(style: .filled, padding: padding, content: content)
    }

    static func interactive<Content: View>(
        style: Style = .elevated,
        padding: Padding = .medium,
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) -> DSCard<Content> {
        DSCard(style: style, padding: padding, action: action, content: content)
    }
}

// MARK: - Previews

@available(iOS 15.0, *)
struct DSCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: DSSpacing.lg) {
                // Elevated card
                DSCard.elevated {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("Elevated Card")
                            .font(DSTypography.h4SwiftUI(weight: .semibold))
                            .foregroundColor(DSColors.primaryTextSwiftUI)

                        Text("This is an elevated card with shadow")
                            .font(DSTypography.bodyMediumSwiftUI())
                            .foregroundColor(DSColors.secondaryTextSwiftUI)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Outlined card
                DSCard.outlined {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("Outlined Card")
                            .font(DSTypography.h4SwiftUI(weight: .semibold))
                            .foregroundColor(DSColors.primaryTextSwiftUI)

                        Text("This is an outlined card with border")
                            .font(DSTypography.bodyMediumSwiftUI())
                            .foregroundColor(DSColors.secondaryTextSwiftUI)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Filled card
                DSCard.filled {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("Filled Card")
                            .font(DSTypography.h4SwiftUI(weight: .semibold))
                            .foregroundColor(DSColors.primaryTextSwiftUI)

                        Text("This is a filled card with background")
                            .font(DSTypography.bodyMediumSwiftUI())
                            .foregroundColor(DSColors.secondaryTextSwiftUI)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Interactive card
                DSCard.interactive(action: {
                    print("Card tapped!")
                }) {
                    HStack {
                        Image(systemName: "film")
                            .font(.title2)
                            .foregroundColor(DSColors.accentSwiftUI)

                        VStack(alignment: .leading, spacing: DSSpacing.xs) {
                            Text("Interactive Card")
                                .font(DSTypography.h4SwiftUI(weight: .semibold))
                                .foregroundColor(DSColors.primaryTextSwiftUI)

                            Text("Tap me!")
                                .font(DSTypography.bodyMediumSwiftUI())
                                .foregroundColor(DSColors.secondaryTextSwiftUI)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(DSColors.secondaryTextSwiftUI)
                    }
                }

                // Custom padding
                DSCard(style: .elevated, padding: .custom(DSSpacing.xl)) {
                    Text("Large Padding Card")
                        .font(DSTypography.h4SwiftUI(weight: .semibold))
                        .foregroundColor(DSColors.primaryTextSwiftUI)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(DSSpacing.lg)
        }
        .background(DSColors.backgroundSwiftUI)
    }
}
