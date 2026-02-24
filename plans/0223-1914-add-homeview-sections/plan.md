---
title: "Add 3 Movie Sections to HomeView"
description: "Add Now Playing, Top Rated, Coming Soon sections using existing fetched data"
status: pending
priority: P2
effort: 1h
branch: master
tags: [swiftui, ios, ui, enhancement]
created: 2026-02-23
---

# Plan: Add 3 Movie Sections to HomeView

## Overview
Add 3 new movie sections to HomeView.swift to display already-fetched data (nowPlayingMovies, topRatedMovies, upcomingMovies) that are currently unused.

## Problem
HomeViewModel fetches 5 movie categories but only displays 2:
- ✅ `trendingMovies` → Hero Carousel
- ✅ `popularMovies` → Most Popular section
- ❌ `nowPlayingMovies` → Not displayed
- ❌ `topRatedMovies` → Not displayed
- ❌ `upcomingMovies` → Not displayed

## Solution
Add 3 sections following the existing "Most Popular" pattern.

## Phases

| # | Phase | Status | Progress |
|---|-------|--------|----------|
| 1 | [Add Movie Sections](./phase-01-add-movie-sections.md) | pending | 0% |

## Files to Modify
- `trending-movie-ios/Presentation/SwiftUI/Views/HomeView.swift`

## Related Docs
- [Brainstorm Report](../reports/brainstorm-0223-1914-homeview-sections.md)

## Success Criteria
- [ ] All 3 sections visible in HomeView
- [ ] Skeleton loading works for each section
- [ ] Movie cards navigate to details
- [ ] Pull-to-refresh updates all sections
- [ ] Consistent styling with existing sections
