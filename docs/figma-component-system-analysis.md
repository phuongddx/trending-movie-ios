# Cinemax Component System Analysis

**Figma Design:** [Cinemax Component System](https://www.figma.com/design/WVtoYFeyU0QXU6Bd803IqM/Cinemax---Movie-Apps-UI-Kit--Community-?node-id=13-111)

**Analysis Date:** September 21, 2025

## Overview

This document analyzes the comprehensive component system from the Cinemax Movie Apps UI Kit. The design includes a complete set of UI components optimized for movie streaming applications, featuring consistent styling, multiple states, and responsive design patterns.

## Component Categories

### 1. Button System

A comprehensive button system with multiple variants, sizes, and states:

#### Button Types
- **Primary**: Main actions with accent color background
- **Default**: Secondary actions with accent color border
- **Text**: Tertiary actions with no background

#### Button Sizes
| Size | Padding | Use Case |
|------|---------|----------|
| **Extra Large** | 18px 24px | Hero CTAs, main actions |
| **Large** | 16px 24px | Important secondary actions |
| **Medium** | 12px 24px | Standard form actions |
| **Small** | 8px 24px | Inline actions, cards |
| **Extra Small** | 4px 24px | Compact UIs, chips |

#### Button States
- **Default**: Normal interactive state
- **Disabled**: Non-interactive state with reduced opacity

#### Button Content
- **Label Only**: Text-based buttons
- **Icon with Label**: Combined icon and text buttons

#### iOS Implementation

```swift
struct DSButton: View {
    enum ButtonType {
        case primary, secondary, text
    }

    enum ButtonSize {
        case extraLarge, large, medium, small, extraSmall

        var padding: EdgeInsets {
            switch self {
            case .extraLarge: return EdgeInsets(top: 18, leading: 24, bottom: 18, trailing: 24)
            case .large: return EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
            case .medium: return EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
            case .small: return EdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24)
            case .extraSmall: return EdgeInsets(top: 4, leading: 24, bottom: 4, trailing: 24)
            }
        }
    }

    let title: String
    let type: ButtonType
    let size: ButtonSize
    let icon: CinemaxIcon?
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    CinemaxIconView(icon, size: .small)
                }
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
            }
            .padding(size.padding)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(borderColor, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 32))
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }

    private var backgroundColor: Color {
        guard !isDisabled else { return DSColors.disabledText }

        switch type {
        case .primary: return DSColors.accent
        case .secondary: return Color.clear
        case .text: return Color.clear
        }
    }

    private var foregroundColor: Color {
        switch type {
        case .primary: return DSColors.primaryText
        case .secondary, .text: return DSColors.accent
        }
    }

    private var borderColor: Color {
        switch type {
        case .primary: return Color.clear
        case .secondary: return DSColors.accent
        case .text: return Color.clear
        }
    }
}
```

### 2. Form Components

#### Input Fields

Multiple input field variants for different data types:

```swift
struct DSInputField: View {
    enum InputType {
        case email, password, search, text

        var keyboardType: UIKeyboardType {
            switch self {
            case .email: return .emailAddress
            case .password, .text, .search: return .default
            }
        }

        var isSecure: Bool {
            self == .password
        }
    }

    @Binding var text: String
    let placeholder: String
    let type: InputType
    let icon: CinemaxIcon?
    let helperText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                if let icon = icon {
                    CinemaxIconView(icon, size: .small, color: DSColors.secondaryText)
                }

                Group {
                    if type.isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .textFieldStyle(PlainTextFieldStyle())
                .keyboardType(type.keyboardType)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(DSColors.primarySoft)
            .clipShape(RoundedRectangle(cornerRadius: 24))

            if let helperText = helperText {
                Text(helperText)
                    .font(.caption)
                    .foregroundColor(DSColors.tertiaryText)
                    .padding(.horizontal, 16)
            }
        }
    }
}
```

#### Toggle Controls

**Switch Component**
```swift
struct DSSwitch: View {
    @Binding var isOn: Bool
    let isDisabled: Bool

    var body: some View {
        Toggle("", isOn: $isOn)
            .toggleStyle(SwitchToggleStyle(tint: DSColors.accent))
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.5 : 1.0)
    }
}
```

**Radio Buttons**
```swift
struct DSRadioButton: View {
    let isSelected: Bool
    let isSquare: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: isSquare ? 4 : 12)
                .stroke(borderColor, lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: isSquare ? 4 : 12)
                        .fill(isSelected ? DSColors.accent : Color.clear)
                )
                .frame(width: 24, height: 24)
                .overlay(
                    Circle()
                        .fill(DSColors.primaryText)
                        .frame(width: 8, height: 8)
                        .opacity(isSelected ? 1 : 0)
                )
        }
    }

    private var borderColor: Color {
        isSelected ? DSColors.accent : DSColors.tertiaryText
    }
}
```

### 3. Navigation Components

#### Tab Navigation
```swift
struct DSTabView: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]

    struct TabItem {
        let title: String
        let icon: CinemaxIcon?
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(tabs.indices, id: \.self) { index in
                TabButton(
                    item: tabs[index],
                    isSelected: selectedTab == index,
                    action: { selectedTab = index }
                )
            }
        }
        .padding(4)
        .background(DSColors.primaryDark)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct TabButton: View {
    let item: DSTabView.TabItem
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = item.icon {
                    CinemaxIconView(icon, size: .small)
                }
                Text(item.title)
                    .font(.body)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? DSColors.primarySoft : Color.clear)
            .foregroundColor(isSelected ? DSColors.primaryText : DSColors.secondaryText)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
```

#### Bottom Navigation
```swift
struct DSBottomNavigation: View {
    @Binding var selectedTab: Int
    let items: [BottomNavItem]

    struct BottomNavItem {
        let icon: CinemaxIcon
        let title: String
    }

    var body: some View {
        HStack {
            ForEach(items.indices, id: \.self) { index in
                BottomNavButton(
                    item: items[index],
                    isSelected: selectedTab == index,
                    action: { selectedTab = index }
                )
                if index < items.count - 1 {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 39)
        .padding(.vertical, 16)
        .background(DSColors.primaryDark)
    }
}

private struct BottomNavButton: View {
    let item: DSBottomNavigation.BottomNavItem
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                CinemaxIconView(
                    item.icon,
                    size: .medium,
                    color: isSelected ? DSColors.accent : DSColors.secondaryText
                )
                Text(item.title)
                    .font(.caption2)
                    .foregroundColor(isSelected ? DSColors.accent : DSColors.secondaryText)
            }
        }
    }
}
```

### 4. Data Display Components

#### Tags
```swift
struct DSTag: View {
    let title: String
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }

    private var backgroundColor: Color {
        if isSelected {
            return DSColors.accent
        } else {
            return DSColors.primarySoft
        }
    }

    private var foregroundColor: Color {
        if isSelected {
            return DSColors.primaryText
        } else {
            return DSColors.secondaryText
        }
    }
}
```

#### Rating Component
```swift
struct DSRating: View {
    let rating: Double
    let maxRating: Int = 5

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { star in
                CinemaxIconView(
                    .star,
                    size: .small,
                    color: star <= Int(rating) ? DSColors.warning : DSColors.tertiaryText
                )
            }
            Text(String(format: "%.1f", rating))
                .font(.caption)
                .foregroundColor(DSColors.secondaryText)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(DSColors.primarySoft.opacity(0.32))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
```

#### Avatar Component
```swift
struct DSAvatar: View {
    enum AvatarType {
        case icon(CinemaxIcon)
        case image(String)
        case text(String)
    }

    let type: AvatarType
    let size: CGFloat

    var body: some View {
        Group {
            switch type {
            case .icon(let icon):
                CinemaxIconView(icon, color: DSColors.primaryText)
            case .image(let imageName):
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .text(let text):
                Text(text.prefix(2).uppercased())
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(DSColors.primaryText)
            }
        }
        .frame(width: size, height: size)
        .background(DSColors.primarySoft)
        .clipShape(Circle())
    }
}
```

### 5. Dropdown Component

```swift
struct DSDropdown: View {
    @State private var isExpanded: Bool = false
    @Binding var selectedOption: String
    let options: [String]
    let placeholder: String
    let isDisabled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Text(selectedOption.isEmpty ? placeholder : selectedOption)
                        .foregroundColor(selectedOption.isEmpty ? DSColors.tertiaryText : DSColors.primaryText)
                    Spacer()
                    CinemaxIconView(
                        .arrowDown,
                        size: .small,
                        color: DSColors.secondaryText
                    )
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(DSColors.primarySoft)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .disabled(isDisabled)

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selectedOption = option
                            isExpanded = false
                        }) {
                            HStack {
                                Text(option)
                                    .foregroundColor(DSColors.primaryText)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(option == selectedOption ? DSColors.accent.opacity(0.1) : Color.clear)
                        }
                    }
                }
                .background(DSColors.primarySoft)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 8)
            }
        }
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}
```

## Component Usage Examples

### Form Example
```swift
struct LoginForm: View {
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false

    var body: some View {
        VStack(spacing: 16) {
            DSInputField(
                text: $email,
                placeholder: "Email",
                type: .email,
                icon: .person,
                helperText: "Enter your email address"
            )

            DSInputField(
                text: $password,
                placeholder: "Password",
                type: .password,
                icon: .padlock
            )

            HStack {
                DSCheckbox(isChecked: $rememberMe)
                Text("Remember me")
                    .font(.body)
                    .foregroundColor(DSColors.secondaryText)
                Spacer()
            }

            DSButton(
                title: "Sign In",
                type: .primary,
                size: .large,
                icon: nil,
                isDisabled: email.isEmpty || password.isEmpty,
                action: { /* Sign in action */ }
            )
        }
        .padding()
    }
}
```

### Navigation Example
```swift
struct MainTabView: View {
    @State private var selectedTab = 0

    private let tabs = [
        DSBottomNavigation.BottomNavItem(icon: .home, title: "Home"),
        DSBottomNavigation.BottomNavItem(icon: .search, title: "Search"),
        DSBottomNavigation.BottomNavItem(icon: .download, title: "Downloads"),
        DSBottomNavigation.BottomNavItem(icon: .person, title: "Profile")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Content based on selected tab
            contentView

            DSBottomNavigation(selectedTab: $selectedTab, items: tabs)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedTab {
        case 0: HomeView()
        case 1: SearchView()
        case 2: DownloadsView()
        case 3: ProfileView()
        default: HomeView()
        }
    }
}
```

## Implementation Guidelines

### 1. Consistency Rules
- Use consistent spacing (8px grid system)
- Apply consistent corner radius (8px, 12px, 24px, 32px)
- Maintain consistent color usage across components
- Follow typography hierarchy

### 2. Accessibility Standards
- Provide proper accessibility labels
- Ensure minimum 44x44pt touch targets
- Support Dynamic Type sizing
- Implement proper contrast ratios

### 3. Performance Optimization
- Use lazy loading for complex components
- Implement efficient state management
- Optimize animations and transitions
- Cache frequently used components

### 4. Testing Requirements
- Unit tests for component logic
- UI tests for user interactions
- Snapshot tests for visual regression
- Accessibility audit compliance

## Next Steps

1. **Implementation Priority**:
   - Phase 1: Button system and basic inputs
   - Phase 2: Navigation components
   - Phase 3: Advanced form components
   - Phase 4: Data display components

2. **Integration Tasks**:
   - Update existing `DesignSystem` components
   - Create component library documentation
   - Implement accessibility features
   - Add comprehensive testing

3. **Quality Assurance**:
   - Cross-device testing
   - Performance benchmarking
   - Accessibility compliance verification
   - User experience validation

---

*This component system provides a robust foundation for building consistent, accessible, and maintainable UI elements throughout the movie streaming application.*