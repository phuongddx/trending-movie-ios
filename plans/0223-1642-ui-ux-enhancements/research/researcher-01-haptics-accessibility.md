# Research Report: SwiftUI Haptic Feedback, Accessibility & Touch Targets (iOS 14+)

**Date:** 2026-02-23
**Focus:** iOS 14+ compatibility patterns for haptics, accessibility, and touch targets

---

## 1. Haptic Feedback in SwiftUI

### 1.1 Approaches by iOS Version

| iOS Version | Recommended Approach | API |
|-------------|---------------------|-----|
| iOS 14-16 | UIKit `UIImpactFeedbackGenerator` | UIKit wrapper |
| iOS 17+ | Native SwiftUI `.sensoryFeedback()` | Built-in modifier |

### 1.2 iOS 14-16: UIKit Wrapper Pattern

```swift
import SwiftUI

// MARK: - Haptic Feedback Helper (iOS 14+)
struct HapticFeedback {
    // Impact feedback styles
    static func impact(_ style: UIImpactFeedbackGenerator.FeededbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare() // Reduces latency
        generator.impactOccurred()
    }

    // Selection feedback
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    // Notification feedback
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}

// MARK: - View Extension for Button Actions
extension View {
    /// Add haptic feedback on tap - iOS 14+ compatible
    func hapticOnTap(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.onTapGesture {
            HapticFeedback.impact(style)
        }
    }
}
```

### 1.3 iOS 17+: Native SwiftUI SensoryFeedback

```swift
// MARK: - iOS 17+ Native Approach
@available(iOS 17.0, *)
struct ModernHapticView: View {
    @State private var isExpanded = false

    var body: some View {
        Button("Toggle") {
            isExpanded.toggle()
        }
        .sensoryFeedback(.impact, trigger: isExpanded)

        // With condition
        .sensoryFeedback(trigger: isExpanded) {
            isExpanded ? .impact : nil
        }

        // With weight and intensity
        .sensoryFeedback(.impact(weight: .heavy, intensity: 0.8), trigger: isExpanded)
    }
}
```

### 1.4 Cross-Version Compatibility Pattern

```swift
import SwiftUI

// MARK: - Cross-Version Haptic Service
struct HapticService {
    /// Impact feedback - works on iOS 14+
    static func impact(style: UIImpactFeedbackGenerator.FeededbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Selection feedback - works on iOS 14+
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    /// Success notification - works on iOS 14+
    static func success() {
        notify(.success)
    }

    /// Warning notification - works on iOS 14+
    static func warning() {
        notify(.warning)
    }

    /// Error notification - works on iOS 14+
    static func error() {
        notify(.error)
    }

    private static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}

// MARK: - Button with Haptic
struct HapticButton<Label: View>: View {
    let action: () -> Void
    let hapticStyle: UIImpactFeedbackGenerator.FeededbackStyle
    let label: () -> Label

    init(
        hapticStyle: UIImpactFeedbackGenerator.FeededbackStyle = .medium,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.hapticStyle = hapticStyle
        self.action = action
        self.label = label
    }

    var body: some View {
        Button(action: {
            HapticService.impact(style: hapticStyle)
            action()
        }, label: label)
    }
}
```

### 1.5 Best Practices

1. **Always call `prepare()`** before triggering to reduce latency
2. **Test on real devices** - simulators don't support haptic feedback
3. **Use appropriate styles**:
   - `.light` - subtle UI elements
   - `.medium` - standard interactions
   - `.heavy` - significant actions
4. **Don't overuse** - haptics should enhance, not distract

---

## 2. Accessibility Best Practices

### 2.1 Core Accessibility Modifiers

| Modifier | Purpose | Best Practice |
|----------|---------|---------------|
| `accessibilityLabel` | Describes what the element is | Concise, capitalize, no element type |
| `accessibilityHint` | Describes what action will occur | Brief, starts with verb |
| `accessibilityValue` | Current value of element | For dynamic content |
| `accessibilityAction` | Custom actions | Use semantic actions |

### 2.2 Implementation Patterns

```swift
import SwiftUI

// MARK: - Icon Button with Accessibility
struct AccessibleIconButton: View {
    let iconName: String
    let label: String
    let hint: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
        }
        .accessibilityLabel(label)
        .accessibilityHint(hint ?? "")
        .frame(width: 44, height: 44) // Touch target compliance
    }
}

// MARK: - Toggle Button with Dynamic Accessibility
struct AccessibleToggleButton: View {
    let isOn: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            Image(systemName: isOn ? "heart.fill" : "heart")
                .foregroundColor(isOn ? .red : .gray)
        }
        .accessibilityLabel(isOn ? "Remove from favorites" : "Add to favorites")
        .accessibilityHint("Double tap to \(isOn ? "remove" : "add")")
        .accessibilityValue(isOn ? "Selected" : "Not selected")
        .frame(width: 44, height: 44)
    }
}

// MARK: - Custom Accessibility Actions
struct MovieCardView: View {
    let movie: Movie
    let onSelect: () -> Void
    let onFavorite: () -> Void
    let onShare: () -> Void

    var body: some View {
        VStack {
            // Card content
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(movie.title), \(movie.voteAverage) stars")
        .accessibilityAction(named: "Add to favorites") {
            onFavorite()
        }
        .accessibilityAction(named: "Share") {
            onShare()
        }
        .onTapGesture {
            onSelect()
        }
    }
}
```

### 2.3 Reduce Motion Support

```swift
import SwiftUI

struct AccessibleAnimatedView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var isExpanded = false

    var body: some View {
        VStack {
            // Content
        }
        .animation(reduceMotion ? .none : .spring(response: 0.3), value: isExpanded)
    }
}

// MARK: - Conditional Animation Modifier
extension View {
    /// Animation that respects Reduce Motion setting
    func accessibleAnimation<V: Equatable>(
        _ animation: Animation = .default,
        value: V
    ) -> some View {
        modifier(AccessibleAnimationModifier(animation: animation, value: value))
    }
}

struct AccessibleAnimationModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let animation: Animation
    let value: V

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? .none : animation, value: value)
    }
}

// Usage
struct ContentView: View {
    @State private var showDetail = false

    var body: some View {
        VStack {
            if showDetail {
                DetailView()
            }
        }
        .accessibleAnimation(.spring(), value: showDetail)
    }
}
```

### 2.4 Accessibility Label Guidelines

```swift
// MARK: - DO: Concise, no element type
Image(systemName: "heart.fill")
    .accessibilityLabel("Favorite")

// MARK: - DON'T: Include element type
Image(systemName: "heart.fill")
    .accessibilityLabel("Favorite button") // VoiceOver already says "button"

// MARK: - DO: Dynamic labels for state
Image(systemName: isPlaying ? "pause.fill" : "play.fill")
    .accessibilityLabel(isPlaying ? "Pause" : "Play")

// MARK: - DO: Combine related elements
HStack {
    Image(systemName: "star.fill")
    Text("4.5")
}
.accessibilityElement(children: .combine)
.accessibilityLabel("4.5 stars")

// MARK: - Multiple input labels for flexibility
Button("John Fitzgerald Kennedy") { }
    .accessibilityInputLabels(["John Fitzgerald Kennedy", "Kennedy", "JFK"])
```

---

## 3. Touch Target Compliance (44x44pt)

### 3.1 Minimum Touch Target Pattern

```swift
import SwiftUI

// MARK: - Minimum Touch Target Constants
struct TouchTarget {
    static let minimumSize: CGFloat = 44
    static let iconSize: CGFloat = 24
}

// MARK: - Touch Target Expansion
extension View {
    /// Expand touch target to minimum 44x44
    func minimumTouchTarget() -> some View {
        self.frame(minWidth: TouchTarget.minimumSize, minHeight: TouchTarget.minimumSize)
            .contentShape(Rectangle())
    }

    /// Expand touch target with custom size
    func touchTarget(size: CGFloat) -> some View {
        self.frame(minWidth: size, minHeight: size)
            .contentShape(Rectangle())
    }
}

// MARK: - Icon Button with Compliant Touch Target
struct CompliantIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20)) // Visual size
                .frame(width: TouchTarget.minimumSize, height: TouchTarget.minimumSize) // Touch size
                .contentShape(Rectangle()) // Expand hit area
        }
    }
}

// MARK: - Small Visual with Large Touch Target
struct CompactActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("Action")
    }
}
```

### 3.2 contentShape Usage Patterns

```swift
import SwiftUI

// MARK: - contentShape for Hit Testing

// Pattern 1: Expand transparent areas
HStack {
    Image(systemName: "star.fill")
    Spacer() // Transparent but tappable
    Text("Favorites")
}
.contentShape(Rectangle()) // Makes entire HStack tappable
.onTapGesture { }

// Pattern 2: Custom shape for hit area
Circle()
    .fill(Color.blue)
    .frame(width: 30, height: 30)
    .contentShape(Circle().size(CGSize(width: 44, height: 44))) // Expand hit area
    .onTapGesture { }

// Pattern 3: Context menu preview
Image("preview")
    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 10))
    .contextMenu {
        Button("Share") { }
        Button("Delete") { }
    }

// Pattern 4: Disable hit testing while keeping visual
Image(systemName: "lock.fill")
    .allowsHitTesting(false) // Not tappable
```

### 3.3 Touch Target Patterns from Current Codebase

Current implementation in `MovieActionsFloating.swift` already uses 44x44:

```swift
// Existing pattern - GOOD
Button(action: onWatchlistTap) {
    Image(systemName: "bookmark.fill")
        .frame(width: 44, height: 44) // Already compliant
        .background(...)
        .clipShape(Circle())
}
```

### 3.4 Complete Touch-Compliant Button Component

```swift
import SwiftUI

// MARK: - Touch-Compliant Button Styles
enum TouchCompliantButtonStyle {
    case icon
    case text
    case iconAndText

    var minSize: CGFloat { 44 }
}

// MARK: - Production-Ready Button
struct TouchCompliantButton: View {
    let icon: String?
    let text: String?
    let style: TouchCompliantButtonStyle
    let action: () -> Void

    init(
        icon: String? = nil,
        text: String? = nil,
        style: TouchCompliantButtonStyle = .icon,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.text = text
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16))
                }
                if let text = text {
                    Text(text)
                        .font(.system(size: 14, weight: .medium))
                }
            }
            .padding(.horizontal, style == .icon ? 0 : 16)
            .frame(
                minWidth: style.minSize,
                minHeight: style.minSize
            )
            .contentShape(Rectangle()) // Critical for hit testing
        }
        .accessibilityLabel(text ?? icon ?? "Button")
    }
}
```

---

## 4. Integration Recommendations

### 4.1 Update Existing `View+Extensions.swift`

```swift
// Add to existing View+Extensions.swift

// MARK: - Enhanced Haptic Feedback
extension View {
    /// Trigger haptic feedback on tap gesture
    func hapticFeedbackOnTap(
        _ style: UIImpactFeedbackGenerator.FeededbackStyle = .medium,
        perform action: @escaping () -> Void
    ) -> some View {
        self.onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
            action()
        }
    }
}

// MARK: - Touch Target Expansion
extension View {
    /// Ensure minimum 44x44 touch target
    func touchTarget(minSize: CGFloat = 44) -> some View {
        self.frame(minWidth: minSize, minHeight: minSize)
            .contentShape(Rectangle())
    }
}

// MARK: - Reduce Motion Support
extension View {
    /// Animation that respects accessibility reduce motion
    func accessibleAnimation<V: Equatable>(
        _ animation: Animation,
        value: V
    ) -> some View {
        modifier(ReduceMotionModifier(animation: animation, value: value))
    }
}

struct ReduceMotionModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let animation: Animation
    let value: V

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? .none : animation, value: value)
    }
}
```

### 4.2 Apply to Existing Components

Based on current codebase analysis, these files need updates:

| File | Enhancement Needed |
|------|-------------------|
| `MovieActions.swift` | Add haptic feedback, expand touch targets |
| `MovieDetailsHeader.swift` | Add touch targets to BlurButton |
| `TabNavigation.swift` | Add haptic on tab selection |

---

## 5. Summary

| Feature | iOS 14+ Solution | Key API |
|---------|-----------------|---------|
| Haptic Feedback | `UIImpactFeedbackGenerator` wrapper | `impactOccurred()` |
| Accessibility Labels | `.accessibilityLabel()` | View modifier |
| Accessibility Hints | `.accessibilityHint()` | View modifier |
| Reduce Motion | `@Environment(\.accessibilityReduceMotion)` | Environment value |
| Touch Targets | `.frame(minWidth: 44, minHeight: 44).contentShape(Rectangle())` | View modifiers |

---

## Sources

- [Apple Developer Documentation - SwiftUI SensoryFeedback](https://developer.apple.com/documentation/SwiftUI/documentation/swiftui/sensoryfeedback/impact%28weight%3Aintensity%3A%29)
- [Apple Developer Documentation - Accessibility Modifiers](https://developer.apple.com/documentation/SwiftUI/documentation/swiftui/view-accessibility)
- [Apple Developer Documentation - contentShape](https://developer.apple.com/documentation/SwiftUI/documentation/swiftui/view/contentshape%28_%3Aeofill%3A%29)
- [WWDC23: Create Accessible Spatial Experiences](https://developer.apple.com/videos/play/wwdc2023/10034/)
- [WWDC21: SwiftUI Accessibility - Beyond the Basics](https://developer.apple.com/cn/videos/play/wwdc2021/10119/)
- [dev.to - Haptic Feedback Guide](https://dev.to/maxnxi/haptic-feedback-and-avaudiosession-conflicts-in-ios-troubleshooting-recording-issues-2ocl)
- [Juejin - SwiftUI 5.0 Touch Feedback](https://juejin.cn/post/7516809395796852788)
- [CSDN - TapticEngine Guide](https://m.blog.csdn.net/gitblog_00567/article/details/141512549)

---

## Unresolved Questions

1. Should haptic feedback be optional/configurable by user preference?
2. Need to audit all icon-only buttons for touch target compliance
3. Consider adding haptic feedback setting in app preferences
