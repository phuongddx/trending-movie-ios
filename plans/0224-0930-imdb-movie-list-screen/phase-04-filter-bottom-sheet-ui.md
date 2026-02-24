# Phase 4: Filter Bottom Sheet UI

## Overview
- **Priority:** P1
- **Status:** Pending
- **Effort:** 4h

Build bottom sheet filter UI with sort, genre, rating, and year sections.

## Context Links
- Filter Models: Phase 3
- Design System: `Presentation/DesignSystem/`
- Existing SearchBar: `Presentation/SwiftUI/Components/SearchBar.swift`

## Requirements

### Functional
- Bottom sheet at 50-70% height
- Sort by section with radio options
- Genre multi-select chips
- Rating slider (0-10)
- Year range pickers
- Apply button with result count
- Clear all button

### Non-Functional
- `.presentationDetents([.medium, .large])`
- Smooth drag indicator
- Haptic feedback on selection

## Architecture

```
MoviesFilterView
├── DragIndicator
├── ScrollView
│   ├── SortSection
│   │   └── Picker(selection: sortBy)
│   ├── GenreSection
│   │   └── LazyVGrid of GenreChip
│   ├── RatingSection
│   │   └── Slider + Value display
│   └── YearSection
│       └── From/To pickers
└── ApplyButton
```

## Related Code Files

| File | Action | Notes |
|------|--------|-------|
| `Presentation/SwiftUI/Components/MoviesFilterView.swift` | Create | Main filter UI |
| `Presentation/SwiftUI/Components/FilterChipView.swift` | Create | Active chips display |
| `Presentation/SwiftUI/Views/MoviesListView.swift` | Modify | Add filter sheet |

## Implementation Steps

### Step 1: Create FilterChipView
```swift
// Presentation/SwiftUI/Components/FilterChipView.swift
import SwiftUI

struct FilterChipView: View {
    let chip: FilterChip
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: DSSpacing.xs) {
            Text(chip.label)
                .font(DSTypography.captionSwiftUI(weight: .medium))
                .foregroundColor(DSColors.primaryTextSwiftUI)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(DSColors.secondaryTextSwiftUI)
            }
            .frame(width: 20, height: 20)
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .background(DSColors.surfaceSwiftUI)
        .cornerRadius(DSSpacing.CornerRadius.medium)
    }
}

// Active Filters Bar
struct ActiveFiltersBar: View {
    @Binding var filters: MovieFilters
    @Binding var showFilterSheet: Bool

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.sm) {
                // Filter button
                Button(action: { showFilterSheet = true }) {
                    HStack(spacing: DSSpacing.xs) {
                        Image(systemName: "slider.horizontal.3")
                        Text("Filter")
                        if filters.isActive {
                            Circle()
                                .fill(DSColors.accentSwiftUI)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .font(DSTypography.bodySmallSwiftUI(weight: .medium))
                    .foregroundColor(filters.isActive ? DSColors.accentSwiftUI : DSColors.secondaryTextSwiftUI)
                }

                // Active chips
                ForEach(filters.activeChips) { chip in
                    FilterChipView(chip: chip) {
                        removeChip(chip)
                    }
                }

                // Clear all (if filters active)
                if filters.isActive {
                    Button("Clear") {
                        filters = .default
                    }
                    .font(DSTypography.captionSwiftUI())
                    .foregroundColor(DSColors.accentSwiftUI)
                }
            }
            .padding(.horizontal, DSSpacing.Padding.container)
        }
    }

    private func removeChip(_ chip: FilterChip) {
        switch chip.category {
        case .sort:
            filters.sortBy = .popularity
        case .genre:
            if let genreId = Int(chip.id.replacingOccurrences(of: "genre_", with: "")) {
                filters.genres.remove(genreId)
            }
        case .rating:
            filters.minimumRating = 0
        case .year:
            let currentYear = Calendar.current.component(.year, from: Date())
            filters.yearRange = 1990...currentYear
        }
    }
}
```

### Step 2: Create MoviesFilterView
```swift
// Presentation/SwiftUI/Components/MoviesFilterView.swift
import SwiftUI
import MoviesDomain

struct MoviesFilterView: View {
    @Binding var filters: MovieFilters
    @Environment(\.dismiss) private var dismiss

    @State private var localFilters: MovieFilters

    init(filters: Binding<MovieFilters>) {
        self._filters = filters
        self._localFilters = State(initialValue: filters.wrappedValue)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.xl) {
                    // Sort Section
                    sortSection

                    // Genre Section
                    genreSection

                    // Rating Section
                    ratingSection

                    // Year Section
                    yearSection
                }
                .padding(DSSpacing.Padding.container)
            }
            .background(DSColors.backgroundSwiftUI)
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") {
                        localFilters = .default
                    }
                    .foregroundColor(localFilters.isActive ? DSColors.accentSwiftUI : DSColors.tertiaryTextSwiftUI)
                    .disabled(!localFilters.isActive)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        filters = localFilters
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(DSColors.accentSwiftUI)
                }
            }
        }
    }

    // MARK: - Sort Section
    private var sortSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Sort By")
                .font(DSTypography.h5SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI)

            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    sortOptionRow(option)
                }
            }
        }
    }

    private func sortOptionRow(_ option: SortOption) -> some View {
        Button(action: { localFilters.sortBy = option }) {
            HStack {
                Text(option.displayName)
                    .font(DSTypography.bodyMediumSwiftUI())
                    .foregroundColor(DSColors.primaryTextSwiftUI)

                Spacer()

                if localFilters.sortBy == option {
                    Image(systemName: "checkmark")
                        .foregroundColor(DSColors.accentSwiftUI)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Genre Section
    private var genreSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Genre")
                .font(DSTypography.h5SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI)

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 100), spacing: DSSpacing.sm)],
                spacing: DSSpacing.sm
            ) {
                ForEach(Genre.all) { genre in
                    genreChip(genre)
                }
            }
        }
    }

    private func genreChip(_ genre: Genre) -> some View {
        Button(action: {
            if localFilters.genres.contains(genre.id) {
                localFilters.genres.remove(genre.id)
            } else {
                localFilters.genres.insert(genre.id)
            }
        }) {
            Text(genre.name)
                .font(DSTypography.captionSwiftUI(weight: .medium))
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xs)
                .foregroundColor(localFilters.genres.contains(genre.id)
                    ? DSColors.primaryTextSwiftUI
                    : DSColors.secondaryTextSwiftUI)
                .background(localFilters.genres.contains(genre.id)
                    ? DSColors.accentSwiftUI
                    : DSColors.surfaceSwiftUI)
                .cornerRadius(DSSpacing.CornerRadius.medium)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Rating Section
    private var ratingSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                Text("Minimum Rating")
                    .font(DSTypography.h5SwiftUI(weight: .semibold))
                    .foregroundColor(DSColors.primaryTextSwiftUI)

                Spacer()

                Text(String(format: "%.1f", localFilters.minimumRating))
                    .font(DSTypography.bodyMediumSwiftUI())
                    .foregroundColor(DSColors.accentSwiftUI)
            }

            Slider(value: $localFilters.minimumRating, in: 0...10, step: 0.5)
                .accentColor(DSColors.accentSwiftUI)

            // Quick rating buttons
            HStack(spacing: DSSpacing.sm) {
                ForEach([5.0, 6.0, 7.0, 8.0], id: \.self) { rating in
                    Button(String(format: "%.0f", rating)) {
                        localFilters.minimumRating = rating
                    }
                    .font(DSTypography.captionSwiftUI(weight: .medium))
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, DSSpacing.xxs)
                    .foregroundColor(localFilters.minimumRating == rating
                        ? DSColors.primaryTextSwiftUI
                        : DSColors.secondaryTextSwiftUI)
                    .background(localFilters.minimumRating == rating
                        ? DSColors.accentSwiftUI
                        : DSColors.surfaceSwiftUI)
                    .cornerRadius(DSSpacing.CornerRadius.small)
                }
            }
        }
    }

    // MARK: - Year Section
    private var yearSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Year Range")
                .font(DSTypography.h5SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI)

            HStack(spacing: DSSpacing.md) {
                VStack(alignment: .leading) {
                    Text("From")
                        .font(DSTypography.captionSwiftUI())
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                    yearPicker(binding: Binding(
                        get: { localFilters.yearRange.lowerBound },
                        set: { localFilters.yearRange = $0...localFilters.yearRange.upperBound }
                    ))
                }

                VStack(alignment: .leading) {
                    Text("To")
                        .font(DSTypography.captionSwiftUI())
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                    yearPicker(binding: Binding(
                        get: { localFilters.yearRange.upperBound },
                        set: { localFilters.yearRange = localFilters.yearRange.lowerBound...$0 }
                    ))
                }
            }
        }
    }

    private func yearPicker(binding: Binding<Int>) -> some View {
        Picker("", selection: binding) {
            ForEach(1990...Calendar.current.component(.year, from: Date()), id: \.self) { year in
                Text(String(year)).tag(year)
            }
        }
        .pickerStyle(.menu)
        .padding(DSSpacing.sm)
        .background(DSColors.surfaceSwiftUI)
        .cornerRadius(DSSpacing.CornerRadius.medium)
    }
}
```

### Step 3: Add Sheet to MoviesListView
```swift
// In MoviesListView
@State private var showFilterSheet = false

// Add modifier to body
.sheet(isPresented: $showFilterSheet) {
    MoviesFilterView(filters: $viewModel.activeFilters)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
}

// Add filter button to header
Button(action: { showFilterSheet = true }) {
    Image(systemName: viewModel.activeFilters.isActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
        .foregroundColor(viewModel.activeFilters.isActive ? DSColors.accentSwiftUI : DSColors.secondaryTextSwiftUI)
}
```

## Todo List

- [ ] Create `FilterChipView.swift`
- [ ] Create `ActiveFiltersBar.swift`
- [ ] Create `MoviesFilterView.swift` with all sections
- [ ] Add `.sheet` modifier to `MoviesListView`
- [ ] Add filter button to header
- [ ] Add haptic feedback on chip selection
- [ ] Test on different screen sizes

## Success Criteria

- [ ] Bottom sheet appears at 50-70% height
- [ ] All filter sections functional
- [ ] Chips update filters correctly
- [ ] Apply button dismisses and applies filters
- [ ] Clear All resets to defaults
- [ ] Active filters show as removable chips

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Sheet too tall on small screens | Medium | Use `.presentationDetents([.medium, .large])` |
| Year picker UX | Low | Use menu picker for compact display |

## Next Steps
- Proceed to Phase 5: API Integration
