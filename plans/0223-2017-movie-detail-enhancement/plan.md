---
title: "MovieDetailView IMDb-Style Enhancement"
description: "Add cast carousel, similar movies, streaming providers, reviews, and full metadata to MovieDetailView"
status: completed
priority: P2
effort: 8h
branch: master
tags: [swiftui, ios, enhancement, tmdb-api]
created: 2026-02-23
completed: 2026-02-23
---

# MovieDetailView IMDb-Style Enhancement

## Overview

Enhance `MovieDetailView` with comprehensive movie information following IMDb-style information-dense design. Add 5 new UI sections plus 2 bug fixes.

## Phase Summary

| Phase | Description | Status | Effort |
|-------|-------------|--------|--------|
| [Phase 1](./phase-01-data-layer.md) | Data Layer - API, DTOs, Model | completed | 2h |
| [Phase 2](./phase-02-ui-components.md) | UI Components - 5 new sections | completed | 3h |
| [Phase 3](./phase-03-integration.md) | Integration - Wire up in View | completed | 2h |
| [Phase 4](./phase-04-bug-fixes.md) | Bug Fixes - CastCrew, BackdropHero | completed | 1h |

## Key Deliverables

### New Features (5 sections)
1. **CastCarouselSection** - Horizontal scroll with cast photos, names, characters
2. **SimilarMoviesSection** - "More like this" carousel with navigation
3. **FullMetadataSection** - Budget, revenue, studios, collection, languages
4. **WhereToWatchSection** - Streaming provider logos (flatrate, rent, buy)
5. **ReviewsSection** - Top 3 user reviews with avatar + rating

### Bug Fixes
- Fix `CastCrewSection` hardcoded writers (use real crew data)
- Fix `MovieBackdropHero` to use `backdropPath` instead of `posterPath`

## Architecture

```
MoviesData (SPM)          MoviesDomain (SPM)         Presentation
     |                          |                          |
MoviesAPI.swift  --->   Movie.swift  --->    MovieDetailsView.swift
TMDBResponseModels       (add fields)          (add sections)
     |                          |                          |
DefaultMoviesRepository  MoviesRepository       ObservableMovieDetailsVM
```

## UI Layout (Top to Bottom)

```
+----------------------------------+
| MovieBackdropHero (fixed)        |
+----------------------------------+
| MovieMetadataBar (existing)      |
+----------------------------------+
| MovieActionButtons (existing)    |
+----------------------------------+
| WhereToWatchSection (NEW)        |  <-- Added here
+----------------------------------+
| StoryLineSection (existing)      |
+----------------------------------+
| CastCrewSection (fixed)          |
+----------------------------------+
| CastCarouselSection (NEW)        |  <-- New cast photos
+----------------------------------+
| FullMetadataSection (NEW)        |
+----------------------------------+
| ReviewsSection (NEW)             |
+----------------------------------+
| SimilarMoviesSection (NEW)       |
+----------------------------------+
```

## Dependencies

- TMDB API (already configured)
- AsyncImage (built-in SwiftUI)
- Design system (`DSColors`, `DSTypography`, `DSSpacing`)

## Related Documents

- Brainstorm: `/plans/reports/brainstorm-0223-2017-movie-detail-enhancement.md`
- API Research: `/plans/reports/researcher-0223-2017-tmdb-apis.md`

## Success Criteria

- [x] All 5 new sections visible and functional
- [x] Cast photos load from real `CastMember` data
- [x] Similar movies carousel navigates to detail
- [x] Streaming providers show US region (graceful fallback)
- [x] Reviews display with author avatar + rating
- [x] BackdropHero uses correct backdrop image
- [x] CastCrewSection uses real crew data

## Risks

| Risk | Mitigation |
|------|------------|
| Missing streaming data | Hide section if empty |
| Long review content | Truncate with "Read more" |
| API rate limiting | Use `append_to_response` pattern |

---

*Created: 2026-02-23*
