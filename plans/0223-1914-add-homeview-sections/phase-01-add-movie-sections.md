---
phase: 1
title: "Add Movie Sections"
status: pending
effort: 1h
dependencies: []
---

# Phase 1: Add Movie Sections

## Context Links
- [Parent Plan](./plan.md)
- [Brainstorm Report](../reports/brainstorm-0223-1914-homeview-sections.md)
- [HomeView.swift](../../trending-movie-ios/Presentation/SwiftUI/Views/HomeView.swift)

## Overview
- **Priority:** P2
- **Implementation Status:** Not Started
- **Review Status:** Pending

Add 3 new horizontal scroll sections to HomeView following the existing "Most Popular" pattern.

## Key Insights
- Data already fetched by HomeViewModel (lines 159-163)
- Pattern exists at lines 86-121 (Most Popular section)
- MovieCard and MovieCardSkeleton components ready to use
- No new dependencies needed

## Requirements

### Functional
- Display "Now Playing" section with `nowPlayingMovies`
- Display "Top Rated" section with `topRatedMovies`
- Display "Coming Soon" section with `upcomingMovies`
- Each section shows max 6 movies in horizontal scroll
- "See All" button placeholder (non-functional for now)

### Non-Functional
- Consistent styling with existing sections
- Skeleton loading during data fetch
- Smooth scrolling performance

## Architecture

```
HomeView.swift (modify)
├── Existing Sections (lines 29-121)
│   ├── UserProfileHeader
│   ├── DSSearchBar
│   ├── Date subtitle
│   ├── HeroCarousel
│   ├── Categories Section
│   └── Most Popular Section
├── NEW: Now Playing Section ← Add here
├── NEW: Top Rated Section ← Add here
├── NEW: Coming Soon Section ← Add here
└── Bottom Spacer (lines 123-125)
```

## Implementation Steps

1. **Add Now Playing Section** (after line 121)
   - Copy Most Popular pattern (lines 86-121)
   - Change title to "Now Playing"
   - Use `viewModel.nowPlayingMovies`
   - Include skeleton loading

2. **Add Top Rated Section**
   - Same pattern
   - Title: "Top Rated"
   - Use `viewModel.topRatedMovies`

3. **Add Coming Soon Section**
   - Same pattern
   - Title: "Coming Soon"
   - Use `viewModel.upcomingMovies`

4. **Test & Verify**
   - Build project
   - Verify all sections display
   - Check skeleton loading
   - Test pull-to-refresh

## Code Template

```swift
// MARK: - Now Playing Section
VStack(alignment: .leading, spacing: 16) {
    HStack {
        Text("Now Playing")
            .font(DSTypography.h4SwiftUI(weight: .semibold))
            .foregroundColor(DSColors.primaryTextSwiftUI)
        Spacer()
        Button("See All") { }
            .font(DSTypography.h5SwiftUI(weight: .medium))
            .foregroundColor(Color(hex: "#12CDD9"))
    }
    .padding(.horizontal, 24)

    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
            if viewModel.isLoading && viewModel.nowPlayingMovies.isEmpty {
                ForEach(0..<6, id: \.self) { _ in
                    MovieCardSkeleton(style: .standard)
                }
            } else {
                ForEach(viewModel.nowPlayingMovies.prefix(6), id: \.id) { movie in
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
}
```

## Todo List
- [ ] Add Now Playing section (copy template, use `nowPlayingMovies`)
- [ ] Add Top Rated section (copy template, use `topRatedMovies`)
- [ ] Add Coming Soon section (copy template, use `upcomingMovies`)
- [ ] Build and verify no compile errors
- [ ] Test on simulator

## Success Criteria
- [ ] 3 new sections visible between "Most Popular" and bottom spacer
- [ ] Each section shows movie cards with proper styling
- [ ] Skeleton loading appears while data loads
- [ ] Tapping movie navigates to details
- [ ] No layout issues or visual regressions

## Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Long scroll UX | Medium | Low | 24px spacing, consistent patterns |
| Performance | Low | Low | LazyHStack already used elsewhere |


## Next Steps
1. Implement sections in HomeView.swift
2. Test on simulator
3. Code review
