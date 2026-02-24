---
title: "IMDb-Style Movie List Screen"
description: "Add filters, view modes, quick actions, infinite scroll to movie list"
status: pending
priority: P2
effort: 16h
issue: null
branch: master
tags: [feature, frontend, swiftui, ios]
created: 2026-02-24
---

# IMDb-Style Movie List Screen Implementation Plan

## Overview

Transform `MoviesListView` into IMDb-style list with:
- Visible quick actions (Watchlist + overflow menu)
- View mode toggle (List/Grid)
- Full filter system with bottom sheet UI
- Infinite scroll with LazyVStack
- Enhanced accessibility

**Brainstorm Report:** [brainstorm-movie-list-screen-design-0224-0930.md](../reports/brainstorm-movie-list-screen-design-0224-0930.md)

## Phases

| # | Phase | Status | Effort | Link |
|---|-------|--------|--------|------|
| 1 | Enhance MovieRowView | Completed | 4h | [phase-01](./phase-01-enhance-movie-row-view.md) |
| 2 | View Mode Toggle | Completed | 2h | [phase-02](./phase-02-view-mode-toggle.md) |
| 3 | Filter System Models | Completed | 3h | [phase-03](./phase-03-filter-system-models.md) |
| 4 | Filter Bottom Sheet UI | Completed | 4h | [phase-04](./phase-04-filter-bottom-sheet-ui.md) |
| 5 | API Integration | Completed | 3h | [phase-05](./phase-05-api-integration.md) |
| 6 | ViewModel Integration | Completed | 2h | [phase-06](./phase-06-viewmodel-integration.md) |
| 7 | Polish & Tests | Completed | 3h | [phase-07](./phase-07-polish-tests.md) |

## Architecture

```
Presentation/SwiftUI/
├── Views/
│   └── MoviesListView.swift          # Enhanced with view modes + filters
├── ViewModels/
│   └── ObservableMoviesListViewModel.swift  # Add filter/view state
├── Components/
│   ├── MovieRowView.swift            # Add action buttons
│   ├── MoviesFilterView.swift        # NEW: Bottom sheet filter
│   ├── ViewModeToggle.swift          # NEW: Segmented control
│   └── FilterChipView.swift          # NEW: Active filter chips
└── Models/
    └── MovieFilters.swift            # NEW: Filter state model

MoviesDomain/Sources/MoviesDomain/
├── Entities/
│   └── MovieFilters.swift            # NEW: Domain filter model
├── UseCases/
│   └── DiscoverMoviesUseCase.swift   # NEW: Filtered movies use case
└── Repositories/
    └── MoviesRepository.swift        # Add discover method

MoviesData/Sources/MoviesData/
├── Network/
│   └── MoviesAPI.swift               # Add discover endpoint
└── Repositories/
    └── DefaultMoviesRepository.swift # Add fetchDiscoverMovies
```

## Key Dependencies

- Design System: `DSColors`, `DSTypography`, `DSSpacing`
- DI Container: `AppContainer`, `PresentationContainer`
- TMDB API: `discover/movie` endpoint for filters
- Storage: `MovieStorage` for watchlist/favorites

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| TMDB discover API params | **High** | Verify API supports all filter params first |
| Filter state persistence | Medium | Use `@AppStorage` for user preferences |
| Infinite scroll performance | Medium | LazyVStack + prefetch + cancel pending |
| View mode layout jump | Low | Use `@ViewBuilder` with switch |

## Resolved Decisions

| Question | Decision | Notes |
|----------|----------|-------|
| Filter persistence | ✅ Persist across launches | Use `@AppStorage("movieFilters")` |
| View mode animation | ✅ Crossfade | `.opacity.combined(with: .scale(scale: 0.95))` |
| Result count in Apply | ✅ Yes, show count | Preflight API call before showing count |

## Implementation Notes

### Filter Persistence
```swift
// Store filters as JSON in AppStorage
@AppStorage("movieFilters") private var storedFilters: Data = Data()

var activeFilters: MovieFilters {
    get { try? JSONDecoder().decode(MovieFilters.self, from: storedFilters) ?? .default }
    set { storedFilters = (try? JSONEncoder().encode(newValue)) ?? Data() }
}
```

### Result Count Preview
- Make lightweight API call with filters to get total_results
- Display in Apply button: "Apply Filters (45 results)"
- Cache count for 5 minutes to avoid repeated calls

## Success Criteria

- [ ] MovieRowView has visible Watchlist button + overflow menu
- [ ] View mode toggle switches List/Grid smoothly
- [ ] Filter bottom sheet with all sections functional
- [ ] Active filters shown as removable chips
- [ ] Infinite scroll loads more movies
- [ ] Pull-to-refresh works
- [ ] All touch targets 44x44pt minimum
- [ ] VoiceOver labels on all interactive elements
