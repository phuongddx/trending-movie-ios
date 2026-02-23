import SwiftUI

// MARK: - Rating Component
@available(iOS 15.0, *)
struct DSRating: View {
    let rating: Double
    let maxRating: Int
    let size: DSIconSize
    let showValue: Bool

    init(
        rating: Double,
        maxRating: Int = 5,
        size: DSIconSize = .small,
        showValue: Bool = true
    ) {
        self.rating = rating
        self.maxRating = maxRating
        self.size = size
        self.showValue = showValue
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { star in
                CinemaxIconView(
                    .star,
                    size: size,
                    color: star <= Int(rating) ? DSColors.warningSwiftUI : DSColors.tertiaryTextSwiftUI
                )
            }

            if showValue {
                Text(String(format: "%.1f", rating))
                    .font(DSTypography.captionSwiftUI())
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(DSColors.surfaceSwiftUI.opacity(0.32))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Tag Component
@available(iOS 15.0, *)
struct DSTag: View {
    let title: String
    let isSelected: Bool
    let isDisabled: Bool
    let style: TagStyle
    let action: () -> Void

    enum TagStyle {
        case `default`
        case pill
        case outlined
    }

    init(
        title: String,
        isSelected: Bool = false,
        isDisabled: Bool = false,
        style: TagStyle = .default,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.isSelected = isSelected
        self.isDisabled = isDisabled
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DSTypography.bodySmallSwiftUI(weight: .medium))
                .foregroundColor(foregroundColor)
                .padding(.horizontal, paddingHorizontal)
                .padding(.vertical, 8)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }

    // MARK: - Private Computed Properties

    private var cornerRadius: CGFloat {
        switch style {
        case .default, .outlined: return 12
        case .pill: return 20
        }
    }

    private var paddingHorizontal: CGFloat {
        switch style {
        case .default, .outlined: return 16
        case .pill: return 20
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .default, .outlined:
            return isSelected ? DSColors.accentSwiftUI : DSColors.surfaceSwiftUI
        case .pill:
            return isSelected
                ? DSColors.accentSwiftUI.opacity(0.15)
                : DSColors.surfaceSwiftUI.opacity(0.8)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .default:
            return isSelected ? DSColors.backgroundSwiftUI : DSColors.secondaryTextSwiftUI
        case .outlined:
            return isSelected ? DSColors.accentSwiftUI : DSColors.secondaryTextSwiftUI
        case .pill:
            return isSelected ? DSColors.accentSwiftUI : DSColors.secondaryTextSwiftUI
        }
    }

    private var borderColor: Color {
        switch style {
        case .default:
            return isSelected ? Color.clear : DSColors.borderSwiftUI.opacity(0.3)
        case .outlined:
            return isSelected ? DSColors.accentSwiftUI : DSColors.borderSwiftUI.opacity(0.5)
        case .pill:
            return DSColors.accentSwiftUI.opacity(isSelected ? 0.8 : 0.3)
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .default: return isSelected ? 0 : 1
        case .outlined: return 1
        case .pill: return 1
        }
    }
}

// MARK: - Search Field Component
@available(iOS 15.0, *)
struct DSSearchField: View {
    @Binding var text: String
    let placeholder: String
    let onSearchTap: (() -> Void)?

    init(
        text: Binding<String>,
        placeholder: String = "Search movies...",
        onSearchTap: (() -> Void)? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSearchTap = onSearchTap
    }

    var body: some View {
        HStack(spacing: 12) {
            CinemaxIconView(.search, size: .small, color: DSColors.secondaryTextSwiftUI)
                .accessibilityHidden(true) // Decorative icon

            TextField(placeholder, text: $text)
                .font(DSTypography.bodyMediumSwiftUI())
                .foregroundColor(DSColors.primaryTextSwiftUI)
                .textFieldStyle(PlainTextFieldStyle())
                .accessibilityLabel("Search movies")
                .accessibilityHint("Type to search for movies")
                .accessibilityAddTraits(.isSearchField)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    CinemaxIconView(.remove, size: .small, color: DSColors.tertiaryTextSwiftUI)
                }
                .accessibilityLabel("Clear search")
                .accessibilityHint("Removes all text from search field")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(DSColors.surfaceSwiftUI)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .onTapGesture {
            onSearchTap?()
        }
    }
}

// MARK: - Input Field Component
@available(iOS 15.0, *)
struct DSInputField: View {
    @Binding var text: String
    let placeholder: String
    let icon: CinemaxIcon?
    let isSecure: Bool
    let helperText: String?
    let errorText: String?

    init(
        text: Binding<String>,
        placeholder: String,
        icon: CinemaxIcon? = nil,
        isSecure: Bool = false,
        helperText: String? = nil,
        errorText: String? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.icon = icon
        self.isSecure = isSecure
        self.helperText = helperText
        self.errorText = errorText
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                if let icon = icon {
                    CinemaxIconView(icon, size: .small, color: DSColors.secondaryTextSwiftUI)
                }

                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .font(DSTypography.bodyMediumSwiftUI())
                .foregroundColor(DSColors.primaryTextSwiftUI)
                .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(DSColors.surfaceSwiftUI)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(borderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 24))

            if let errorText = errorText {
                Text(errorText)
                    .font(DSTypography.captionSwiftUI())
                    .foregroundColor(DSColors.errorSwiftUI)
                    .padding(.horizontal, 16)
            } else if let helperText = helperText {
                Text(helperText)
                    .font(DSTypography.captionSwiftUI())
                    .foregroundColor(DSColors.tertiaryTextSwiftUI)
                    .padding(.horizontal, 16)
            }
        }
    }

    private var borderColor: Color {
        if errorText != nil {
            return DSColors.errorSwiftUI
        } else {
            return Color.clear
        }
    }
}

// MARK: - Toggle Component
@available(iOS 15.0, *)
struct DSToggle: View {
    @Binding var isOn: Bool
    let label: String
    let isDisabled: Bool

    init(
        isOn: Binding<Bool>,
        label: String,
        isDisabled: Bool = false
    ) {
        self._isOn = isOn
        self.label = label
        self.isDisabled = isDisabled
    }

    var body: some View {
        HStack {
            Text(label)
                .font(DSTypography.bodyMediumSwiftUI())
                .foregroundColor(DSColors.primaryTextSwiftUI)

            Spacer()

            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: DSColors.accentSwiftUI))
                .disabled(isDisabled)
        }
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}

// MARK: - Dropdown Component
@available(iOS 15.0, *)
struct DSDropdown: View {
    @State private var isExpanded: Bool = false
    @Binding var selectedOption: String
    let options: [String]
    let placeholder: String
    let isDisabled: Bool

    init(
        selectedOption: Binding<String>,
        options: [String],
        placeholder: String,
        isDisabled: Bool = false
    ) {
        self._selectedOption = selectedOption
        self.options = options
        self.placeholder = placeholder
        self.isDisabled = isDisabled
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() } }) {
                HStack {
                    Text(selectedOption.isEmpty ? placeholder : selectedOption)
                        .font(DSTypography.bodyMediumSwiftUI())
                        .foregroundColor(selectedOption.isEmpty ? DSColors.tertiaryTextSwiftUI : DSColors.primaryTextSwiftUI)
                    Spacer()
                    CinemaxIconView(
                        .arrowDown,
                        size: .small,
                        color: DSColors.secondaryTextSwiftUI
                    )
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(DSColors.surfaceSwiftUI)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .disabled(isDisabled)

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selectedOption = option
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isExpanded = false
                            }
                        }) {
                            HStack {
                                Text(option)
                                    .font(DSTypography.bodyMediumSwiftUI())
                                    .foregroundColor(DSColors.primaryTextSwiftUI)
                                Spacer()
                                if option == selectedOption {
                                    CinemaxIconView(.tick, size: .small, color: DSColors.accentSwiftUI)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(option == selectedOption ? DSColors.accentSwiftUI.opacity(0.1) : Color.clear)
                        }
                    }
                }
                .background(DSColors.surfaceSwiftUI)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}

// MARK: - Section Header Component
@available(iOS 15.0, *)
struct DSSectionHeader<TrailingContent: View>: View {
    let title: String
    let icon: CinemaxIcon
    let trailingContent: TrailingContent

    init(
        title: String,
        icon: CinemaxIcon,
        @ViewBuilder trailingContent: () -> TrailingContent = { EmptyView() }
    ) {
        self.title = title
        self.icon = icon
        self.trailingContent = trailingContent()
    }

    var body: some View {
        HStack {
            CinemaxIconView(icon, size: .small, color: DSColors.accentSwiftUI)
                .accessibilityHidden(true)

            Text(title)
                .font(DSTypography.h5SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI)

            Spacer()

            trailingContent
        }
    }
}

// MARK: - Section Header without trailing content convenience init
extension DSSectionHeader where TrailingContent == EmptyView {
    init(title: String, icon: CinemaxIcon) {
        self.init(title: title, icon: icon, trailingContent: { EmptyView() })
    }
}