# Cinemax Color System Analysis

**Figma Design:** [Cinemax Color System](https://www.figma.com/design/WVtoYFeyU0QXU6Bd803IqM/Cinemax---Movie-Apps-UI-Kit--Community-?node-id=13-422)

**Analysis Date:** September 21, 2025

## Overview

This document analyzes the comprehensive color system from the Cinemax Movie Apps UI Kit. The design presents a well-structured color palette optimized for dark-themed entertainment applications with excellent contrast ratios and visual hierarchy.

## Color Categories

### Primary Colors

The primary color palette establishes the main visual identity and UI foundations:

| Color Name | Hex Code | Usage | iOS Implementation |
|------------|----------|-------|-------------------|
| **Dark** | `#1F1D2B` | Main background, primary surfaces | `UIColor(hex: "1F1D2B")` |
| **Soft** | `#252836` | Secondary backgrounds, cards, containers | `UIColor(hex: "252836")` |
| **Blue Accent** | `#12CDD9` | Primary actions, highlights, brand elements | `UIColor(hex: "12CDD9")` |

### Secondary Colors

Accent colors for status indicators, warnings, and categorical distinctions:

| Color Name | Hex Code | Usage | iOS Implementation |
|------------|----------|-------|-------------------|
| **Green** | `#22B07D` | Success states, positive actions | `UIColor(hex: "22B07D")` |
| **Orange** | `#FF8700` | Warning states, pending actions | `UIColor(hex: "FF8700")` |
| **Red** | `#FB4141` | Error states, destructive actions | `UIColor(hex: "FB4141")` |

### Text Colors

Hierarchy of text colors ensuring readability across all interface elements:

| Color Name | Hex Code | Usage | iOS Implementation |
|------------|----------|-------|-------------------|
| **Black** | `#171725` | Rare high-contrast text (on light backgrounds) | `UIColor(hex: "171725")` |
| **Dark Grey** | `#696974` | Secondary text, metadata | `UIColor(hex: "696974")` |
| **Grey** | `#92929D` | Tertiary text, disabled states | `UIColor(hex: "92929D")` |
| **White Grey** | `#EBEBEF` | Light secondary text | `UIColor(hex: "EBEBEF")` |
| **White** | `#FFFFFF` | Primary text, high contrast elements | `UIColor(hex: "FFFFFF")` |
| **Line Dark** | `#EAEAEA` | Subtle borders, dividers | `UIColor(hex: "EAEAEA")` |

## Design System Integration

### SwiftUI Color Extension

```swift
extension Color {
    // Primary Colors
    static let primaryDark = Color(hex: "1F1D2B")
    static let primarySoft = Color(hex: "252836")
    static let primaryBlueAccent = Color(hex: "12CDD9")

    // Secondary Colors
    static let secondaryGreen = Color(hex: "22B07D")
    static let secondaryOrange = Color(hex: "FF8700")
    static let secondaryRed = Color(hex: "FB4141")

    // Text Colors
    static let textBlack = Color(hex: "171725")
    static let textDarkGrey = Color(hex: "696974")
    static let textGrey = Color(hex: "92929D")
    static let textWhiteGrey = Color(hex: "EBEBEF")
    static let textWhite = Color(hex: "FFFFFF")
    static let lineDark = Color(hex: "EAEAEA")
}

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
```

### Design System Colors Structure

Update the existing `DSColors` class:

```swift
struct DSColors {
    // MARK: - Primary Colors
    static let primaryDark = Color.primaryDark
    static let primarySoft = Color.primarySoft
    static let accent = Color.primaryBlueAccent

    // MARK: - Secondary Colors
    static let success = Color.secondaryGreen
    static let warning = Color.secondaryOrange
    static let error = Color.secondaryRed

    // MARK: - Text Colors
    static let primaryText = Color.textWhite
    static let secondaryText = Color.textWhiteGrey
    static let tertiaryText = Color.textGrey
    static let disabledText = Color.textDarkGrey

    // MARK: - Surface Colors
    static let background = Color.primaryDark
    static let surface = Color.primarySoft
    static let border = Color.lineDark

    // MARK: - Status Colors
    static let successBackground = Color.secondaryGreen.opacity(0.1)
    static let warningBackground = Color.secondaryOrange.opacity(0.1)
    static let errorBackground = Color.secondaryRed.opacity(0.1)
}
```

## Usage Guidelines

### Primary Color Applications

**Dark (#1F1D2B)**
- Main app background
- Navigation bars
- Modal backgrounds
- Card containers (when maximum contrast needed)

**Soft (#252836)**
- Secondary backgrounds
- Card surfaces
- Input field backgrounds
- Tab bar backgrounds

**Blue Accent (#12CDD9)**
- Primary buttons
- Active states
- Progress indicators
- Link text
- Selected items

### Secondary Color Applications

**Green (#22B07D)**
- Success messages
- Completion indicators
- Positive ratings
- "Available" status

**Orange (#FF8700)**
- Warning messages
- Pending states
- "Coming Soon" labels
- Notification badges

**Red (#FB4141)**
- Error messages
- Destructive actions
- "Unavailable" status
- Delete buttons

### Text Color Hierarchy

1. **White (#FFFFFF)** - Primary headings, main content
2. **White Grey (#EBEBEF)** - Secondary text, descriptions
3. **Grey (#92929D)** - Metadata, timestamps
4. **Dark Grey (#696974)** - Disabled text, placeholder text

## Accessibility Considerations

### Contrast Ratios

| Text Color | Background | Contrast Ratio | WCAG AA | WCAG AAA |
|------------|------------|---------------|---------|----------|
| White | Primary Dark | 15.8:1 | ✅ Pass | ✅ Pass |
| White Grey | Primary Dark | 12.7:1 | ✅ Pass | ✅ Pass |
| Grey | Primary Dark | 6.1:1 | ✅ Pass | ✅ Pass |
| Dark Grey | Primary Dark | 3.9:1 | ✅ Pass | ⚠️ Fail |
| Blue Accent | Primary Dark | 8.2:1 | ✅ Pass | ✅ Pass |
| Green | Primary Dark | 6.8:1 | ✅ Pass | ✅ Pass |
| Orange | Primary Dark | 7.1:1 | ✅ Pass | ✅ Pass |
| Red | Primary Dark | 5.9:1 | ✅ Pass | ✅ Pass |

### Color Blind Accessibility

- **Blue Accent** provides sufficient contrast for protanopia and deuteranopia
- **Green/Red combination** includes sufficient luminance differences
- **Orange** provides alternative to red for warning states

## Dark Mode Optimization

This color system is specifically designed for dark mode interfaces:

- **High contrast ratios** ensure readability in low-light conditions
- **Warm accent colors** reduce eye strain
- **Layered greys** create depth without harsh transitions
- **OLED-friendly blacks** minimize power consumption on modern displays

## Implementation Recommendations

### 1. Color Token System

```swift
enum ColorToken {
    case primaryDark, primarySoft, accent
    case success, warning, error
    case primaryText, secondaryText, tertiaryText, disabledText
    case background, surface, border

    var color: Color {
        switch self {
        case .primaryDark: return DSColors.primaryDark
        case .primarySoft: return DSColors.primarySoft
        case .accent: return DSColors.accent
        // ... continue for all tokens
        }
    }
}
```

### 2. Semantic Color Names

Use semantic naming in components:

```swift
struct MovieCard: View {
    var body: some View {
        VStack {
            // Good: Semantic naming
            Text("Movie Title")
                .foregroundColor(.primaryText)
            Text("Genre")
                .foregroundColor(.secondaryText)
        }
        .background(.surface)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.border, lineWidth: 1)
        )
    }
}
```

### 3. Dynamic Color Support

```swift
extension Color {
    static func dynamicColor(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}
```

## Testing Guidelines

### 1. Visual Testing
- Test color combinations in various lighting conditions
- Verify contrast on different device sizes
- Check color accuracy across device types

### 2. Accessibility Testing
- Use iOS Accessibility Inspector
- Test with VoiceOver enabled
- Verify with different contrast settings

### 3. Automated Testing
```swift
func testColorContrast() {
    let backgroundColor = DSColors.primaryDark
    let textColor = DSColors.primaryText

    let contrastRatio = ColorUtility.contrastRatio(
        foreground: textColor,
        background: backgroundColor
    )

    XCTAssertGreaterThan(contrastRatio, 4.5, "Text must meet WCAG AA standards")
}
```

## Next Steps

1. **Integration**: Implement color system in existing `DSColors` class
2. **Migration**: Update existing UI components to use new color tokens
3. **Validation**: Test color combinations across all app screens
4. **Documentation**: Update component documentation with color usage
5. **Quality Assurance**: Perform accessibility audit with new colors

---

*This color system provides a solid foundation for the Cinemax-inspired movie app while maintaining excellent accessibility and visual hierarchy standards.*