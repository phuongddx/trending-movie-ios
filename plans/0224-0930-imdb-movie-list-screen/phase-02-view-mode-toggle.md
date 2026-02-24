# Phase 2: View Mode Toggle

## Overview
- **Priority:** P2
- **Status:** Pending
- **Effort:** 2h

Add segmented control to switch between List and Grid views.

## Context Links
- Design System: `Presentation/DesignSystem/`
- MoviesListView: `trending-movie-ios/Presentation/SwiftUI/Views/MoviesListView.swift`

## Requirements

### Functional
- Segmented control with List/Grid icons
- Persist selection in `@AppStorage`
- Smooth transition between modes

### Non-Functional
- Use SF Symbols: `list.bullet` and `square.grid.2x2`
- 44x44pt touch targets

## Architecture

```swift
enum ViewMode: String, CaseIterable {
    case list = "list"
    case grid = "grid"
}
```

## Related Code Files

| File | Action | Notes |
|------|--------|-------|
| `Presentation/SwiftUI/Components/ViewModeToggle.swift` | Create | Segmented control |
| `Presentation/SwiftUI/Views/MoviesListView.swift` | Modify | Add toggle to header |
| `Presentation/SwiftUI/ViewModels/ObservableMoviesListViewModel.swift` | Modify | Add viewMode property |

## Implementation Steps

### Step 1: Create ViewModeToggle Component
```swift
// Presentation/SwiftUI/Components/ViewModeToggle.swift
import SwiftUI

struct ViewModeToggle: View {
    @Binding var mode: ViewMode

    var body: some View {
        Picker("", selection: $mode) {
            Image(systemName: "list.bullet")
                .tag(ViewMode.list)
                .accessibilityLabel("List view")

            Image(systemName: "square.grid.2x2")
                .tag(ViewMode.grid)
                .accessibilityLabel("Grid view")
        }
        .pickerStyle(.segmented)
        .frame(width: 100)
    }
}

enum ViewMode: String, CaseIterable {
    case list = "list"
    case grid = "grid"

    var icon: String {
        switch self {
        case .list: return "list.bullet"
        case .grid: return "square.grid.2x2"
        }
    }
}
```

### Step 2: Add to ViewModel
```swift
// In ObservableMoviesListViewModel
@AppStorage("moviesViewMode") var viewMode: ViewMode = .list
```

### Step 3: Update MoviesListView Header
```swift
private var headerView: some View {
    HStack {
        Text(viewModel.moviesListHeaderTitle)
            .font(DSTypography.h4SwiftUI(weight: .semibold))
            .foregroundColor(DSColors.primaryTextSwiftUI)

        Spacer()

        ViewModeToggle(mode: $viewModel.viewMode)

        themeToggleButton
    }
    .padding(.bottom, DSSpacing.sm)
}
```

### Step 4: Create Conditional Content View
```swift
@ViewBuilder
private var moviesContentView: some View {
    switch viewModel.viewMode {
    case .list:
        moviesListView
    case .grid:
        moviesGridView
    }
}

private var moviesListView: some View {
    // Existing LazyVStack implementation
}

private var moviesGridView: some View {
    let columns = [
        GridItem(.adaptive(minimum: 135, maximum: 180), spacing: DSSpacing.md)
    ]

    return LazyVGrid(columns: columns, spacing: DSSpacing.md) {
        ForEach(Array(viewModel.movies.enumerated()), id: \.element.title) { index, movie in
            MovieCard(movie: movie, style: .standard) {
                viewModel.selectMovie(at: index)
            }
            .onAppear {
                if index == viewModel.movies.count - 3 {
                    viewModel.loadNextPage()
                }
            }
        }
    }
}
```

## Todo List

- [ ] Create `ViewModeToggle.swift` component
- [ ] Add `ViewMode` enum
- [ ] Add `@AppStorage("moviesViewMode")` to ViewModel
- [ ] Add toggle to `MoviesListView` header
- [ ] Create `moviesGridView` with `LazyVGrid`
- [ ] Create `@ViewBuilder` content switcher
- [ ] Test mode persistence across app restarts

## Success Criteria

- [ ] Toggle shows List and Grid icons
- [ ] Tapping switches between views
- [ ] Selection persists after app restart
- [ ] Smooth transition between modes

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Layout jump on toggle | Low | Use `@ViewBuilder` with switch |
| AppStorage not syncing | Low | Use `@AppStorage` property wrapper |

## Next Steps
- Proceed to Phase 3: Filter System Models
