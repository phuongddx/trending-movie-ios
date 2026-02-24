---
title: "Phase 5: Reduce Motion Support"
description: "Respect system Reduce Motion accessibility setting"
status: completed
priority: P2
effort: 1h
phase: 5 of 6
---

# Phase 5: Reduce Motion Support

## Context Links

- Research: [Haptics & Accessibility Research](./research/researcher-01-haptics-accessibility.md)
- Apple: [Reduce Motion](https://support.apple.com/en-us/HT202655)

## Overview

Implement support for the system Reduce Motion accessibility setting. Users who are sensitive to motion can enable this setting to reduce or eliminate animations throughout iOS. Our app should respect this preference.

## Current State Analysis

| Component | Current Animation | Reduce Motion Handling |
|-----------|------------------|----------------------|
| `DSActionButton` | Scale 0.95 press | Not handled |
| `DSIconButton` | Scale 0.9 press | Not handled |
| `CategoryTabs` | EaseInOut 0.2s | Not handled |
| `MoviePosterImage` | Opacity 0.3s | Not handled |
| `ShimmerModifier` | Linear 1.5s | Already handled (Phase 3) |
| `View+Extensions` | bounceAnimation, smoothAnimation | Not handled |

## Requirements

### Functional
- All animations respect `@Environment(\.accessibilityReduceMotion)`
- When enabled: instant transitions or simple crossfades
- When disabled: existing animations preserved

### Non-Functional
- No animation jank when toggling setting
- Consistent behavior across all animated views
- Centralized animation modifier for reuse

## Animation Fallbacks

| Original Animation | Reduce Motion Fallback |
|-------------------|----------------------|
| Spring (bounce) | None (instant) |
| Scale 0.95/0.9 | None |
| EaseInOut 0.2s | None (instant) |
| Opacity fade 0.3s | Crossfade 0.15s |
| Shimmer 1.5s | Static overlay |

## Related Code Files

### Files to Modify
- `trending-movie-ios/Presentation/Utils/Extensions/View+Extensions.swift`
- `trending-movie-ios/Presentation/DesignSystem/Components/DSActionButton.swift`
- `trending-movie-ios/Presentation/SwiftUI/Components/CategoryTabs.swift`
- `trending-movie-ios/Presentation/SwiftUI/Components/MoviePosterImage.swift`

## Implementation Steps

### Step 1: Add AccessibleAnimationModifier to View+Extensions.swift

```swift
// MARK: - Reduce Motion Support

/// Animation that respects accessibility Reduce Motion setting
struct AccessibleAnimationModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let animation: Animation
    let value: V

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? .none : animation, value: value)
    }
}

/// Conditional animation that respects Reduce Motion
struct ConditionalAnimationModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let normalAnimation: Animation
    let reducedAnimation: Animation
    let value: V

    func body(content: Content) -> some View {
        content.animation(
            reduceMotion ? reducedAnimation : normalAnimation,
            value: value
        )
    }
}

extension View {
    /// Apply animation that respects Reduce Motion setting
    func accessibleAnimation<V: Equatable>(
        _ animation: Animation,
        value: V
    ) -> some View {
        modifier(AccessibleAnimationModifier(animation: animation, value: value))
    }

    /// Apply conditional animation with different reduced motion fallback
    func conditionalAnimation<V: Equatable>(
        normal: Animation,
        reduced: Animation = .easeInOut(duration: 0.15),
        value: V
    ) -> some View {
        modifier(ConditionalAnimationModifier(
            normalAnimation: normal,
            reducedAnimation: reduced,
            value: value
        ))
    }
}
```

### Step 2: Update Existing Animation Helpers

```swift
// Update in View+Extensions.swift:
// MARK: - Animation Utilities

/// Bounce animation (respects Reduce Motion)
func bounceAnimation<V: Equatable>(value: V) -> some View {
    modifier(AccessibleAnimationModifier(
        animation: .spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0),
        value: value
    ))
}

/// Smooth animation (respects Reduce Motion)
func smoothAnimation<V: Equatable>(duration: Double = 0.3, value: V) -> some View {
    modifier(AccessibleAnimationModifier(
        animation: .easeInOut(duration: duration),
        value: value
    ))
}
```

### Step 3: Update DSActionButton

```swift
// In DSActionButton:
@Environment(\.accessibilityReduceMotion) var reduceMotion

// In body, update scaleEffect animation:
.scaleEffect(isPressed ? 0.95 : 1.0)
.opacity(isDisabled ? 0.5 : 1.0)
.animation(reduceMotion ? .none : .easeInOut(duration: 0.1), value: isPressed)
```

### Step 4: Update DSIconButton

```swift
// In DSIconButton:
@Environment(\.accessibilityReduceMotion) var reduceMotion

// In body, update scaleEffect animation:
.scaleEffect(isPressed ? 0.9 : 1.0)
.opacity(isDisabled ? 0.5 : 1.0)
.animation(reduceMotion ? .none : .easeInOut(duration: 0.1), value: isPressed)
```

### Step 5: Update CategoryTabs

```swift
// In CategoryTab:
@Environment(\.accessibilityReduceMotion) var reduceMotion

// In body, update selection animation:
Button(action: {
    HapticManager.shared.selection()
    withAnimation(reduceMotion ? .none : .easeInOut(duration: 0.2)) {
        selectedCategory = category
    }
}) {
    // ... content
}
```

### Step 6: Update MoviePosterImage

```swift
// In MoviePosterImage:
@Environment(\.accessibilityReduceMotion) var reduceMotion

// In body, update transition:
if let image = image {
    Image(uiImage: image)
        .resizable()
        .aspectRatio(aspectRatio, contentMode: .fill)
        .transition(reduceMotion ? .opacity : .opacity.animation(.easeInOut(duration: 0.3)))
} else {
    // ...
}
```

## Todo List

- [ ] Add `AccessibleAnimationModifier` to `View+Extensions.swift`
- [ ] Add `accessibleAnimation()` view extension
- [ ] Update `bounceAnimation()` to accept value parameter
- [ ] Update `smoothAnimation()` to accept value parameter
- [ ] Add `@Environment(\.accessibilityReduceMotion)` to `DSActionButton`
- [ ] Update `DSActionButton` scale animation
- [ ] Add `@Environment(\.accessibilityReduceMotion)` to `DSIconButton`
- [ ] Update `DSIconButton` scale animation
- [ ] Update `CategoryTab` selection animation
- [ ] Update `MoviePosterImage` transition
- [ ] Build and verify no compile errors
- [ ] Test with Reduce Motion enabled

## Success Criteria

- [ ] All button press animations disabled with Reduce Motion
- [ ] Tab selection instant with Reduce Motion
- [ ] Image transitions simplified with Reduce Motion
- [ ] Shimmer static with Reduce Motion (from Phase 3)
- [ ] No compile errors

## Testing with Reduce Motion

1. Enable: Settings > Accessibility > Motion > Reduce Motion (ON)
2. Restart app
3. Verify:
   - Button presses have no scale animation
   - Tab switches are instant
   - Image loads have minimal/no animation
   - Shimmer shows static gray

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Missed animations | Audit all `.animation()` calls |
| Inconsistent behavior | Use centralized modifier |
| Breaking existing code | Keep existing helpers, add new ones |

## Next Steps

After completion:
- Proceed to Phase 6: Pull to Refresh
- All accessibility improvements complete

---

*Phase 5 of 6 | Estimated: 1h*
