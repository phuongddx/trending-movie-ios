---
title: "Phase 3: Loading States Enhancement"
description: "Implement shimmer loading effects and skeleton components"
status: completed
priority: P2
effort: 2h
phase: 3 of 6
---

# Phase 3: Loading States Enhancement

## Context Links

- Research: [Shimmer & Loading Patterns Research](./research/researcher-02-shimmer-images.md)
- Related: `MoviePosterImage.swift`, `HomeView.swift`

## Overview

Add shimmer loading effects to improve perceived performance. When images are loading, users see an animated placeholder instead of a static gray box. This creates a more polished, modern feel.

## Current State Analysis

| Component | Current State | Issue |
|-----------|---------------|-------|
| `MoviePosterImage` | Static gray placeholder + icon | No animation, feels static |
| `MovieCard` | No loading state | Uses AsyncImage with no shimmer |
| `HomeView` | Has `DSHeroCarouselSkeleton` | Only skeleton, no shimmer on images |

## Requirements

### Functional
- Shimmer animation on loading images
- Skeleton views matching actual content layout
- Animation stops immediately when content loads
- Smooth transition from shimmer to content

### Non-Functional
- Maximum 3 concurrent shimmer animations per screen (performance)
- 1.5 second animation duration
- Works on iOS 14+
- No external dependencies

## Architecture

```
ShimmerModifier (ViewModifier)
├── Linear gradient mask animation
├── 1.5s linear repeat animation
└── Stops on disappear

Skeleton Components
├── SkeletonRectangle (shimmer + placeholder)
├── SkeletonCircle (shimmer + circle)
└── MovieCardSkeleton (composed)
```

## Related Code Files

### Files to Create
- `trending-movie-ios/Presentation/DesignSystem/Modifiers/ShimmerModifier.swift`
- `trending-movie-ios/Presentation/SwiftUI/Components/SkeletonViews.swift`

### Files to Modify
- `trending-movie-ios/Presentation/SwiftUI/Components/MoviePosterImage.swift`
- `trending-movie-ios/Presentation/Utils/Extensions/View+Extensions.swift` (add shimmer extension)

## Implementation Steps

### Step 1: Create ShimmerModifier.swift

```swift
// Path: trending-movie-ios/Presentation/DesignSystem/Modifiers/ShimmerModifier.swift
import SwiftUI

/// Shimmer loading effect modifier
struct ShimmerModifier: ViewModifier {
    @State private var isInitialState = true
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func body(content: Content) -> some View {
        if reduceMotion {
            // Static gray for reduce motion
            content
                .overlay(Color.gray.opacity(0.3))
        } else {
            content
                .mask(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .black.opacity(0.4),
                            .black,
                            .black.opacity(0.4)
                        ]),
                        startPoint: isInitialState ? UnitPoint(x: -0.3, y: -0.3) : UnitPoint(x: 1, y: 1),
                        endPoint: isInitialState ? UnitPoint(x: 0, y: 0) : UnitPoint(x: 1.3, y: 1.3)
                    )
                )
                .onAppear {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        isInitialState = false
                    }
                }
        }
    }
}

// MARK: - View Extension
extension View {
    /// Apply shimmer loading effect
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
```

### Step 2: Create SkeletonViews.swift

```swift
// Path: trending-movie-ios/Presentation/SwiftUI/Components/SkeletonViews.swift
import SwiftUI

// MARK: - Skeleton Rectangle
struct SkeletonRectangle: View {
    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat

    init(width: CGFloat? = nil, height: CGFloat, cornerRadius: CGFloat = 8) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        Rectangle()
            .fill(DSColors.surfaceSwiftUI)
            .frame(width: width, height: height)
            .cornerRadius(cornerRadius)
            .shimmer()
    }
}

// MARK: - Movie Card Skeleton
struct MovieCardSkeleton: View {
    let style: MovieCard.Style

    init(style: MovieCard.Style = .standard) {
        self.style = style
    }

    var body: some View {
        switch style {
        case .standard:
            standardSkeleton
        case .hero:
            heroSkeleton
        case .compact:
            compactSkeleton
        }
    }

    private var standardSkeleton: some View {
        VStack(spacing: 0) {
            SkeletonRectangle(width: 135, height: 178, cornerRadius: 12)
                .cornerRadius(12, corners: [.topLeft, .topRight])

            VStack(alignment: .leading, spacing: 4) {
                SkeletonRectangle(width: 100, height: 16, cornerRadius: 4)
                SkeletonRectangle(width: 60, height: 12, cornerRadius: 4)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .frame(width: 135, alignment: .leading)
        }
        .background(DSColors.surfaceSwiftUI)
        .cornerRadius(12)
    }

    private var heroSkeleton: some View {
        VStack(alignment: .leading, spacing: 16) {
            SkeletonRectangle(width: nil, height: 300, cornerRadius: 0)

            VStack(alignment: .leading, spacing: 8) {
                SkeletonRectangle(width: 200, height: 24, cornerRadius: 4)
                SkeletonRectangle(width: 100, height: 14, cornerRadius: 4)
            }
            .padding(.horizontal, 20)
        }
    }

    private var compactSkeleton: some View {
        HStack(spacing: 12) {
            SkeletonRectangle(width: 60, height: 90, cornerRadius: 8)

            VStack(alignment: .leading, spacing: 8) {
                SkeletonRectangle(width: 150, height: 16, cornerRadius: 4)
                SkeletonRectangle(width: 80, height: 12, cornerRadius: 4)
                SkeletonRectangle(width: nil, height: 12, cornerRadius: 4)
            }

            Spacer()
        }
        .padding(16)
        .background(DSColors.surfaceSwiftUI)
        .cornerRadius(12)
    }
}

// MARK: - Preview
struct SkeletonViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            MovieCardSkeleton(style: .standard)
            MovieCardSkeleton(style: .compact)
        }
        .padding()
        .background(DSColors.backgroundSwiftUI)
    }
}
```

### Step 3: Update MoviePosterImage.swift

Add shimmer to the placeholder:

```swift
// In MoviePosterImage, update placeholderView:
@ViewBuilder
private var placeholderView: some View {
    if showPlaceholder {
        Rectangle()
            .fill(DSColors.surfaceSwiftUI)
            .overlay(
                CinemaxIconView(
                    .film,
                    size: iconSize,
                    color: DSColors.tertiaryTextSwiftUI
                )
            )
            .shimmer() // ADD THIS LINE
    } else {
        EmptyView()
    }
}
```

### Step 4: Update HomeView for Loading States

```swift
// In HomeView Most Popular section, add loading state:
ScrollView(.horizontal, showsIndicators: false) {
    HStack(spacing: 12) {
        if viewModel.isLoading && viewModel.popularMovies.isEmpty {
            ForEach(0..<6, id: \.self) { _ in
                MovieCardSkeleton(style: .standard)
            }
        } else {
            ForEach(viewModel.popularMovies.prefix(6), id: \.id) { movie in
                MovieCard(
                    movie: movie,
                    style: .standard,
                    onTap: { viewModel.selectMovie(movie) }
                )
            }
        }
    }
    .padding(.horizontal, 24)
}
```

## Todo List

- [ ] Create `ShimmerModifier.swift` with reduce motion support
- [ ] Add `.shimmer()` extension to `View+Extensions.swift` (or in ShimmerModifier file)
- [ ] Create `SkeletonViews.swift` with skeleton components
- [ ] Update `MoviePosterImage.swift` placeholder to use shimmer
- [ ] Update `HomeView.swift` to show skeleton during loading
- [ ] Build and verify no compile errors
- [ ] Test shimmer animation appearance

## Success Criteria

- [ ] Shimmer animation visible on loading images
- [ ] Animation respects Reduce Motion setting
- [ ] Skeleton views match actual content layout
- [ ] No compile errors
- [ ] Works on iOS 14+

## Performance Considerations

| Guideline | Reason |
|-----------|--------|
| Max 3 shimmer per screen | GPU-intensive animation |
| Linear animation (1.5s) | Smooth but not distracting |
| Stop on content load | Prevent unnecessary GPU usage |
| Static for Reduce Motion | Accessibility compliance |

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Performance on older devices | Limit concurrent shimmers |
| Animation jank | Use linear, not spring animation |
| Battery drain | Stop shimmer when view disappears |

## Next Steps

After completion:
- Proceed to Phase 4: Accessibility Improvements
- Loading states now provide polished UX

---

*Phase 3 of 6 | Estimated: 2h*
