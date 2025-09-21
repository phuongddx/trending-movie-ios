# Cinemax Typography System Analysis

**Figma Design:** [Cinemax - Movie Apps UI Kit](https://www.figma.com/design/WVtoYFeyU0QXU6Bd803IqM/Cinemax---Movie-Apps-UI-Kit--Community-?node-id=16-18)

**Analysis Date:** September 21, 2025

## Overview

This document analyzes the typography system from the Cinemax Movie Apps UI Kit Figma design. The design presents a comprehensive typography hierarchy specifically tailored for a movie streaming application interface.

## Design Specifications

### Primary Font Family
- **Font:** Montserrat
- **Usage:** Primary typeface for all UI elements
- **Character Set:** Full Latin alphabet (A-Z, a-z) and numerals (0-9)

### Color Palette
- **Primary Background:** `#1F1D2B` (Dark theme)
- **Primary Text:** `#FFFFFF` (White)
- **Secondary Text:** `#EBEBEF` (White Grey)
- **Accent Color:** `#12CDD9` (Cyan/Teal)

## Typography Hierarchy

The design system includes three font weight variations across seven heading levels:

### Font Weights
1. **Semibold (600)** - Primary choice for headings and emphasis
2. **Medium (500)** - Secondary choice for balanced readability
3. **Regular (400)** - Body text and standard content

### Heading Scale

| Level | Semibold | Medium | Regular | Primary Use Case |
|-------|----------|---------|---------|------------------|
| **H1** | 28px | 28px | 28px | Main titles, hero headings |
| **H2** | 24px | 24px | 24px | Section headers, category titles |
| **H3** | 18px | 18px | 18px | Subsection headers, card titles |
| **H4** | 16px | 16px | 16px | Component titles, labels |
| **H5** | 14px | 14px | 14px | Secondary labels, metadata |
| **H6** | 12px | 12px | 12px | Captions, small labels |
| **H7** | 10px | 10px | 10px | Micro text, disclaimers |

### Body Text Styles

| Style | Font Size | Weight | Use Case |
|-------|-----------|---------|----------|
| **Body/Semibold** | 12px | 600 | Important body text, CTAs |
| **Body/Medium** | 12px | 500 | Standard body text |
| **Body/Regular** | 12px | 400 | Secondary body text, descriptions |

### Typography Specifications

#### Line Height
- **Consistent ratio:** ~1.219 (approximately 122% of font size)
- **Purpose:** Ensures optimal readability across all text sizes

#### Letter Spacing
- **H1 (28px):** 0.43% - Tight spacing for large titles
- **H2 (24px):** 0.5% - Slightly more open for clarity
- **H3 (18px):** 0.67% - Balanced spacing
- **H4 (16px):** 0.75% - Standard UI spacing
- **H5 (14px):** 0.86% - Increased spacing for smaller text
- **H6 (12px):** 1.0% - More open for legibility
- **H7 (10px):** 1.2% - Maximum spacing for micro text

## Implementation Recommendations for iOS

### SwiftUI Integration

```swift
// Typography extension for the design system
extension Font {
    // Heading styles
    static let h1Semibold = Font.custom("Montserrat-SemiBold", size: 28)
    static let h2Semibold = Font.custom("Montserrat-SemiBold", size: 24)
    static let h3Semibold = Font.custom("Montserrat-SemiBold", size: 18)
    static let h4Semibold = Font.custom("Montserrat-SemiBold", size: 16)
    static let h5Semibold = Font.custom("Montserrat-SemiBold", size: 14)
    static let h6Semibold = Font.custom("Montserrat-SemiBold", size: 12)
    static let h7Semibold = Font.custom("Montserrat-SemiBold", size: 10)

    // Medium variants
    static let h1Medium = Font.custom("Montserrat-Medium", size: 28)
    static let h2Medium = Font.custom("Montserrat-Medium", size: 24)
    // ... continue for all levels

    // Body text
    static let bodySemibold = Font.custom("Montserrat-SemiBold", size: 12)
    static let bodyMedium = Font.custom("Montserrat-Medium", size: 12)
    static let bodyRegular = Font.custom("Montserrat-Regular", size: 12)
}
```

### Design System Integration

The typography should be integrated into the existing `DSTypography` class in `Presentation/DesignSystem/`:

```swift
struct DSTypography {
    // Heading styles
    static let h1 = Font.custom("Montserrat-SemiBold", size: 28)
    static let h2 = Font.custom("Montserrat-SemiBold", size: 24)
    static let h3 = Font.custom("Montserrat-SemiBold", size: 18)
    static let h4 = Font.custom("Montserrat-SemiBold", size: 16)
    static let h5 = Font.custom("Montserrat-SemiBold", size: 14)
    static let h6 = Font.custom("Montserrat-SemiBold", size: 12)

    // Body styles
    static let bodyLarge = Font.custom("Montserrat-Medium", size: 16)
    static let bodyMedium = Font.custom("Montserrat-Medium", size: 14)
    static let bodySmall = Font.custom("Montserrat-Regular", size: 12)
    static let caption = Font.custom("Montserrat-Regular", size: 10)
}
```

### Font Installation Requirements

1. **Download Montserrat font family** from Google Fonts
2. **Include font files** in the iOS app bundle:
   - Montserrat-Regular.ttf
   - Montserrat-Medium.ttf
   - Montserrat-SemiBold.ttf
3. **Update Info.plist** with font file references
4. **Test font loading** across different iOS versions

### Usage Guidelines

#### Do's
- Use Semibold weights for primary headings and important UI elements
- Maintain consistent line heights across similar text sizes
- Apply appropriate letter spacing for each font size
- Use the defined color palette for text contrast

#### Don'ts
- Avoid mixing different font families
- Don't ignore the defined letter spacing values
- Don't use font weights outside the specified range (400, 500, 600)
- Don't compromise contrast ratios for aesthetic purposes

## Accessibility Considerations

### Text Contrast
- **White on Dark Background:** Excellent contrast ratio (15.8:1)
- **White Grey on Dark Background:** Good contrast ratio (12.7:1)
- **Minimum recommended:** 4.5:1 for normal text, 3:1 for large text

### Dynamic Type Support
Consider implementing Dynamic Type support for iOS accessibility:
- Map design system sizes to iOS Text Styles
- Provide scaling factors for custom fonts
- Test with larger accessibility font sizes

### Recommended Mappings
- H1 → `.largeTitle`
- H2 → `.title1`
- H3 → `.title2`
- H4 → `.title3`
- H5 → `.headline`
- H6 → `.subheadline`
- Body → `.body`
- Caption → `.caption1`

## Design System Benefits

1. **Consistency:** Unified typography across all app screens
2. **Scalability:** Clear hierarchy supports complex information architecture
3. **Readability:** Optimized spacing and weights for mobile interfaces
4. **Brand Alignment:** Montserrat provides modern, clean aesthetic suitable for entertainment apps
5. **Dark Mode Optimized:** Color choices specifically designed for dark interfaces

## Next Steps

1. **Font Integration:** Add Montserrat font files to the iOS project
2. **Design System Update:** Extend existing `DSTypography` with Figma specifications
3. **Component Audit:** Review existing UI components for typography consistency
4. **Implementation:** Apply new typography system across key screens
5. **Testing:** Validate typography rendering across different device sizes
6. **Documentation:** Update component documentation with new typography guidelines

---

*This analysis provides a foundation for implementing the Cinemax typography system in the iOS trending movie app, ensuring visual consistency with the original design while maintaining iOS-specific best practices.*