---
title: "Phase 2: Touch Target Compliance"
description: "Ensure all interactive elements meet 44x44pt minimum touch target"
status: completed
priority: P1
effort: 1h
phase: 2 of 6
---

# Phase 2: Touch Target Compliance

## Context Links

- Research: [Haptics & Accessibility Research](./research/researcher-01-haptics-accessibility.md)
- Apple HIG: [Human Interface Guidelines - Interaction](https://developer.apple.com/design/human-interface-guidelines/ios/user-interaction/gestures/)

## Overview

Apple's Human Interface Guidelines require a minimum touch target of 44x44 points for all interactive elements. Current `DSIconButton` has a `.small` size of 32x32, which is below the minimum. This phase fixes all touch target violations.

## Current State Analysis

| Component | Current Size | Status |
|-----------|--------------|--------|
| DSIconButton.small | 32x32 | **FAILS** - Below 44pt |
| DSIconButton.medium | 44x44 | Passes |
| DSIconButton.large | 56x56 | Passes |
| DSIconButton.extraLarge | 72x72 | Passes |
| DSActionButton.extraSmall | ~36x28 | **FAILS** - Below 44pt height |
| DSActionButton.small | ~40x24 | **FAILS** - Below 44pt height |
| CategoryTab | Variable | May fail on small devices |

## Requirements

### Functional
- All interactive elements have minimum 44x44pt touch target
- Visual size can remain smaller while touch target expands
- Use `contentShape(Rectangle())` to expand hit area

### Non-Functional
- Maintain visual design integrity
- Transparent areas around small buttons become tappable
- No visual regression

## Architecture

```
Touch Target Pattern:
┌─────────────────────────┐
│    44x44 (touch area)   │
│   ┌─────────────────┐   │
│   │  32x32 (visual) │   │
│   └─────────────────┘   │
└─────────────────────────┘
```

## Related Code Files

### Files to Modify
- `trending-movie-ios/Presentation/DesignSystem/Components/DSActionButton.swift`
- `trending-movie-ios/Presentation/Utils/Extensions/View+Extensions.swift`

## Implementation Steps

### Step 1: Add Touch Target Extension to View+Extensions.swift

```swift
// MARK: - Touch Target Compliance

/// Minimum touch target size per Apple HIG
struct TouchTarget {
    static let minimumSize: CGFloat = 44
}

extension View {
    /// Expand touch target to minimum 44x44
    func minimumTouchTarget() -> some View {
        self.frame(minWidth: TouchTarget.minimumSize, minHeight: TouchTarget.minimumSize)
            .contentShape(Rectangle())
    }

    /// Expand touch target with custom minimum size
    func touchTarget(minSize: CGFloat = TouchTarget.minimumSize) -> some View {
        self.frame(minWidth: minSize, minHeight: minSize)
            .contentShape(Rectangle())
    }
}
```

### Step 2: Update DSIconButton Small Size

The small icon button visual should remain 32x32 but touch area expands to 44x44.

```swift
// In DSIconButton body:
Button(action: {
    HapticManager.shared.lightImpact()
    action()
}) {
    CinemaxIconView(icon, size: size, color: foregroundColor)
        // Keep visual size for small, but expand touch target
        .frame(width: iconVisualSize, height: iconVisualSize)
        .frame(minWidth: TouchTarget.minimumSize, minHeight: TouchTarget.minimumSize)
        .background(backgroundColor)
        // ... rest of styling
        .contentShape(Rectangle()) // Critical: expand hit area
}

// Add computed property:
private var iconVisualSize: CGFloat {
    switch size {
    case .small: return 32      // Visual stays 32
    case .medium: return 44
    case .large: return 56
    case .extraLarge: return 72
    }
}
```

### Step 3: Update DSActionButton Sizes

For text buttons, ensure the frame meets 44pt minimum height.

```swift
// In DSActionButton body, modify padding/frame:
HStack(spacing: 8) {
    // ... content
}
.padding(size.padding)
.frame(maxWidth: .infinity)
.frame(minHeight: TouchTarget.minimumSize) // Add minimum height
.background(backgroundColor)
// ... rest of styling
.contentShape(Rectangle()) // Expand hit area to frame
```

### Step 4: Update CategoryTab

```swift
// In CategoryTab body:
Button(action: action) {
    Text(title)
        .font(DSTypography.h6SwiftUI(weight: .medium))
        .foregroundColor(isSelected ? Color(hex: "#12CDD9") : DSColors.secondaryTextSwiftUI)
        .padding(.horizontal, isSelected ? 32 : 12)
        .padding(.vertical, 8)
        .frame(minHeight: TouchTarget.minimumSize) // Add minimum height
        .background(isSelected ? DSColors.surfaceSwiftUI : Color.clear)
        .cornerRadius(8)
        .contentShape(Rectangle()) // Expand hit area
}
```

### Step 5: Audit MovieCard Compact Actions

The compact card uses `.small` DSIconButton which now has compliant touch targets.

```swift
// In MovieCard.swift compactCard, verify:
DSIconButton(
    icon: isInWatchlist ? .download : .downloadOffline,
    style: .secondary,
    size: .small,  // Now has 44x44 touch target
    action: onWatchlistTap
)
```

## Todo List

- [ ] Add `TouchTarget` constants and view extension to `View+Extensions.swift`
- [ ] Update `DSIconButton` with visual vs touch size separation
- [ ] Add `contentShape(Rectangle())` to `DSIconButton`
- [ ] Update `DSActionButton` with minimum height constraint
- [ ] Add `contentShape(Rectangle())` to `DSActionButton`
- [ ] Update `CategoryTab` with minimum height and contentShape
- [ ] Build and verify no compile errors
- [ ] Test with Accessibility Inspector

## Success Criteria

- [ ] All buttons have minimum 44x44pt touch target
- [ ] Visual appearance unchanged
- [ ] No compile errors
- [ ] Accessibility Inspector confirms touch targets

## Testing with Accessibility Inspector

1. Open Xcode > Open Developer Tool > Accessibility Inspector
2. Select the iOS Simulator as target
3. Use the inspector to click on small buttons
4. Verify "Hit Rect" shows at least 44x44

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Visual layout changes | Use frame minWidth/minHeight, not fixed size |
| Overlapping touch targets | Test with complex layouts like compact cards |
| contentShape affects other gestures | Test with existing gesture handlers |

## Security Considerations

- None - purely UI improvement

## Next Steps

After completion:
- Proceed to Phase 3: Loading States Enhancement
- Touch targets are now compliant for App Store review

---

*Phase 2 of 6 | Estimated: 1h*
