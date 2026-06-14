# Design Guidelines

## Overview
The Trending Movies iOS app features a Cinemax-inspired design system built with SwiftUI, emphasizing dark theme aesthetics and consistent component architecture. This document serves as a comprehensive index pointing to detailed design documentation and specifications.

## Design System Documentation

### Core Design Documents
The design system is documented through five comprehensive analysis files:

1. **[Cinemax Design System Overview](./cinemax-design-system-overview.md)**
   - Overview of Cinemax design principles and visual language
   - Design philosophy and brand guidelines
   - System architecture and component relationships

2. **[Figma Color System Analysis](./figma-color-system-analysis.md)**
   - Detailed color palette breakdown and usage guidelines
   - Color psychology and emotional impact
   - Accessibility and contrast requirements
   - Implementation specifications

3. **[Figma Component System Analysis](./figma-component-system-analysis.md)**
   - Component library breakdown and usage patterns
   - Interactive states and behavior specifications
   - Responsive design principles
   - Implementation guidelines

4. **[Figma Icon System Analysis](./figma-icon-system-analysis.md)**
   - Icon taxonomy and naming conventions
   - Icon styles and visual specifications
   - Icon usage guidelines and spacing
   - Implementation details

5. **[Figma Typography Analysis](./figma-typography-analysis.md)**
   - Typography hierarchy and usage guidelines
   - Font specifications and pairing recommendations
   - Responsive typography principles
   - Implementation specifications

## Design System Implementation

### DSColors - Color System
The color system is implemented in `trending-movie-ios/Presentation/DesignSystem/Colors/DSColors.swift`:

**Primary Colors**:
- `primaryDark`: #1F1D2B (main background)
- `primarySoft`: #252836 (card/surface background)
- `blueAccent`: #12CDD9 (primary accent color)

**Semantic Colors**:
- Background: `primaryDark`
- Surface: `primarySoft`
- Primary Text: White
- Secondary Text: `textWhiteGrey`
- Accent: `blueAccent`

**Status Colors**:
- Success: `successGreen` (#22B07D)
- Warning: `warningOrange` (#FF8700)
- Error: `errorRed` (#FB4141)

**Color Usage Guidelines**:
- Always use predefined DSColors constants
- Never use hardcoded color values
- Support both UIColor (UIKit) and Color (SwiftUI)
- Include accessibility contrast validation

### DSTypography - Typography System
Typography is implemented in `trending-movie-ios/Presentation/DesignSystem/Typography/DSTypography.swift`:

**Font Family**: Montserrat (with system fallbacks)
**Font Weights**: Regular, Medium, Semibold

**Typography Hierarchy**:
- **H1**: 28pt (hero titles)
- **H2**: 24pt (movie titles, section headers)
- **H3**: 18pt (subheaders, important text)
- **H4**: 16pt (body text emphasis)
- **H5**: 14pt (regular body text)
- **H6**: 12pt (small body text)
- **H7**: 10pt (captions, metadata)
- **Body Large**: 16pt (large body text)
- **Body Medium**: 14pt (regular body text)
- **Body Small**: 12pt (small body text)
- **Caption**: 10pt (tiny text, labels)

**Implementation Guidelines**:
- Always use semantic style functions (`.h1()`, `.bodyMedium()`, etc.)
- Prefer SwiftUI extensions for modern UI development
- Use DSTextStyle for complex text styling
- Include proper line height for improved readability

### DSSpacing - Spacing System
Spacing follows an 8pt grid system implemented in `trending-movie-ios/Presentation/DesignSystem/Spacing/DSSpacing.swift`:

**Base Unit**: 8pt grid
**Spacing Scale**:
- `xxxs`: 2pt
- `xxs`: 4pt
- `xs`: 6pt
- `sm`: 8pt
- `md`: 12pt
- `lg`: 16pt
- `xl`: 20pt
- `xxl`: 24pt
- `xxxl`: 32pt
- `xxxxl`: 40pt

**Component Spacing**:
- **Container Padding**: 16pt
- **Card Padding**: 12pt
- **Button Padding**: 8pt
- **Cell Padding**: 16pt

**Layout Guidelines**:
- Always use DSSpacing constants for consistency
- Follow the 8pt grid system
- Use proper touch targets (44pt minimum)
- Apply appropriate corner radius for components

## Design Principles

### 1. Dark Theme First
- Primary design aesthetic is dark theme
- Light mode support with appropriate color adaptations
- High contrast for accessibility
- Proper readability in low-light environments

### 2. Component-Based Architecture
- Modular, reusable components
- Consistent API across all components
- Proper state management and lifecycle handling
- Accessibility and testing support

### 3. Cinemax Visual Language
- Bold, modern aesthetic
- Clean typography with Montserrat font family
- Strategic use of blue accent colors
- Professional entertainment industry styling

### 4. Responsive Design
- Adaptive layouts for different screen sizes
- Proper spacing scaling
- Touch-friendly interaction targets
- Performance-optimized animations

## Component Usage Guidelines

### UI Components
The design system includes extensive SwiftUI components:

**Interactive Components**:
- `DSActionButton`: Primary action buttons
- `DSIconButton`: Icon-based interactive elements
- `DSTabView`: Tab navigation components
- `DSSearchBar`: Search input with modern styling
- `DSLoadingView`: Loading states with shimmer effects

**Display Components**:
- `DSLoadingView`: Loading indicators
- `DSCarouselSkeleton`: Skeleton loading states
- `DSFormComponents`: Form inputs and controls
- `MovieCard`: Movie information cards
- `FilterChipView`: Filter selection chips

**Layout Components**:
- HeroCarousel: Featured movie carousel
- CategoryTabs: Category navigation
- MoviePosterImage: Optimized image display
- EmptyStateView: Empty content states
- ErrorView: Error display components

### Implementation Patterns

#### Basic Component Usage
```swift
// Button with DS styling
Button("Search") {
    // Action
}
.buttonStyle(DSActionButtonStyle())

// Text with typography
Text("Movie Title")
.font(.h2())
.foregroundStyle(.primaryText)

// Spacing application
padding(.horizontal, .lg)
padding(.vertical, .md)
```

#### Advanced Component Usage
```swift
// Movie card with proper styling
MovieCard(movie: movie)
.padding(.md)
.background(.surface)
.cornerRadius(.medium)

// Search bar with icon
SearchBar(text: $searchText, placeholder: "Search movies...")
.padding(.lg)
.background(.surface)
.cornerRadius(.large)
```

## Accessibility Guidelines

### Color Contrast
- Minimum 4.5:1 contrast for normal text
- Minimum 3:1 contrast for large text
- Avoid color-only information conveyance
- Test with Dynamic Type support

### Typography Accessibility
- Support Dynamic Type scaling
- Proper line height and spacing
- Clear visual hierarchy
- Readable font sizes across weights

### Interactive Elements
- Minimum 44pt touch targets
- Proper spacing between interactive elements
- Focus indicators for VoiceOver
- Haptic feedback for important actions

## Performance Considerations

### Image Optimization
- Use MoviePosterImage for proper caching
- Implement lazy loading for movie posters
- Optimize image sizes for different screen densities
- Use efficient image formats (WebP where supported)

### Animation Performance
- Use native SwiftUI animations
- Avoid expensive animations on list items
- Implement proper animation curves
- Test performance on lower-end devices

### Memory Management
- Proper cleanup of resources in ViewModels
- Avoid memory leaks in closures
- Use weak references where appropriate
- Implement proper state management

## Design System Maintenance

### Updates and Changes
- Follow semantic versioning for design system changes
- Maintain backward compatibility where possible
- Update all usage examples when making changes
- Document breaking changes in release notes

### Quality Assurance
- Regular design system audits
- Component usage consistency checks
- Accessibility validation
- Performance testing with design updates

## Design Resources

### Figma Files
- **Main Design System**: Available in Figma with component library
- **Token System**: Design tokens integrated with code implementation
- **Documentation**: Comprehensive design documentation in Figma

### Code Resources
- **DesignSystem Module**: All design system code in `Presentation/DesignSystem/`
- **Component Catalog**: Detailed component usage examples
- **Style Guides**: Implementation guidelines and best practices

### Testing Resources
- **Accessibility Testing**: VoiceOver and Dynamic Type testing
- **Performance Testing**: Animation and memory usage validation
- **Visual Testing**: Visual regression testing for design consistency

## Future Enhancements

### Planned Design System Updates
1. **Dynamic Theming**: Support for user-customizable themes
2. **Component Variants**: Additional component states and variations
3. **Motion Design**: Enhanced animation patterns and micro-interactions
4. **Accessibility Improvements**: Advanced accessibility features

### Integration Opportunities
1. **Widget Support**: Design system extension for app widgets
2. **WatchOS Support**: Adapt design system for Apple Watch
3. **MacOS Support**: Desktop adaptation of design principles
4. **Cross-Platform Consistency**: Maintain design consistency across platforms

---

**Note**: This document serves as an index and summary. For detailed implementation specifications, refer to the individual design analysis files and the actual code implementation in the DesignSystem module.