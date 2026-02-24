# Phase 5: Visual Hierarchy

**Status:** Pending
**Priority:** Medium
**Effort:** Low
**Est. Time:** 30 min
**Depends on:** Phase 4

---

## Overview

Improve visual hierarchy with results count header, enhanced tag styling, and section headers with icons.

## Requirements

### Functional
- Results count displayed above search results
- Pill-style tags with accent border
- Section headers with icons

### Non-Functional
- Consistent spacing using DSSpacing
- Visual weight appropriate to importance

## Implementation Steps

### Step 1: Add Results Count Header

**File:** `SearchView.swift`

```swift
private var resultsCountHeader: some View {
    HStack {
        Text("\(viewModel.totalResults) movies found")
            .font(DSTypography.bodySmallSwiftUI())
            .foregroundColor(DSColors.secondaryTextSwiftUI)

        Spacer()

        if viewModel.searchResults.count > 0 {
            Text("Page \(viewModel.currentPage) of \(viewModel.totalPages)")
                .font(DSTypography.captionSwiftUI())
                .foregroundColor(DSColors.tertiaryTextSwiftUI)
        }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 8)
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(viewModel.totalResults) movies found")
}
```

### Step 2: Update SearchViewModel with Total Count

**File:** `SearchViewModel.swift`

```swift
@MainActor
class SearchViewModel: ObservableObject {
    // ... existing properties ...

    // Add total results tracking
    @Published var totalResults: Int = 0

    private func handleSearchResult(_ moviesPage: MoviesPage, isLoadingMore: Bool) {
        totalPages = moviesPage.totalPages
        totalResults = moviesPage.totalResults // NEW

        // ... rest of implementation ...
    }
}
```

### Step 3: Create Enhanced Pill Tag

**File:** `DSFormComponents.swift` (enhance existing DSTag)

```swift
@available(iOS 15.0, *)
struct DSTag: View {
    let title: String
    let isSelected: Bool
    let isDisabled: Bool
    let style: TagStyle
    let action: () -> Void

    enum TagStyle {
        case `default`
        case pill
        case outlined
    }

    init(
        title: String,
        isSelected: Bool = false,
        isDisabled: Bool = false,
        style: TagStyle = .default,
        action: @escaping () -> Void = {}
    ) {
        self.title = title
        self.isSelected = isSelected
        self.isDisabled = isDisabled
        self.style = style
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(DSTypography.bodySmallSwiftUI(weight: .medium))
                .foregroundColor(foregroundColor)
                .padding(.horizontal, paddingHorizontal)
                .padding(.vertical, 8)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
    }

    // MARK: - Private Computed Properties

    private var cornerRadius: CGFloat {
        switch style {
        case .default, .outlined: return 12
        case .pill: return 20
        }
    }

    private var paddingHorizontal: CGFloat {
        switch style {
        case .default, .outlined: return 16
        case .pill: return 20
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .default, .outlined:
            return isSelected ? DSColors.accentSwiftUI : DSColors.surfaceSwiftUI
        case .pill:
            return isSelected
                ? DSColors.accentSwiftUI.opacity(0.15)
                : DSColors.surfaceSwiftUI.opacity(0.8)
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .default:
            return isSelected ? DSColors.backgroundSwiftUI : DSColors.secondaryTextSwiftUI
        case .outlined:
            return isSelected ? DSColors.accentSwiftUI : DSColors.secondaryTextSwiftUI
        case .pill:
            return isSelected ? DSColors.accentSwiftUI : DSColors.secondaryTextSwiftUI
        }
    }

    private var borderColor: Color {
        switch style {
        case .default:
            return isSelected ? Color.clear : DSColors.borderSwiftUI.opacity(0.3)
        case .outlined:
            return isSelected ? DSColors.accentSwiftUI : DSColors.borderSwiftUI.opacity(0.5)
        case .pill:
            return DSColors.accentSwiftUI.opacity(isSelected ? 0.8 : 0.3)
        }
    }

    private var borderWidth: CGFloat {
        switch style {
        case .default: return isSelected ? 0 : 1
        case .outlined: return 1
        case .pill: return 1
        }
    }
}
```

### Step 4: Create Section Header Component

**File:** `SearchView.swift` (or create DSFormComponents.swift extension)

```swift
struct SectionHeader: View {
    let title: String
    let icon: CinemaxIcon
    var trailingContent: AnyView? = nil

    init(
        title: String,
        icon: CinemaxIcon,
        @ViewBuilder trailingContent: () -> some View = { EmptyView() }
    ) {
        self.title = title
        self.icon = icon
        self.trailingContent = AnyView(trailingContent())
    }

    var body: some View {
        HStack {
            CinemaxIconView(icon, size: .small, color: DSColors.accentSwiftUI)
                .accessibilityHidden(true)

            Text(title)
                .font(DSTypography.h5SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI)

            Spacer()

            trailingContent
        }
    }
}

// Usage example
SectionHeader(title: "Popular Searches", icon: .flame) {
    Button("See All") {
        // Action
    }
    .font(DSTypography.captionSwiftUI())
    .foregroundColor(DSColors.accentSwiftUI)
}
```

### Step 5: Update All Section Headers in SearchView

**File:** `SearchView.swift`

```swift
// Replace manual headers with SectionHeader component

// Recent searches section
SectionHeader(title: "Recent Searches", icon: .clock) {
    Button("Clear") {
        viewModel.clearSearchHistory()
    }
    .font(DSTypography.captionSwiftUI())
    .foregroundColor(DSColors.tertiaryTextSwiftUI)
}

// Trending section
SectionHeader(title: "Trending Now", icon: .trending)

// Popular searches section
SectionHeader(title: "Popular Searches", icon: .flame)

// No results suggestions
SectionHeader(title: "Try searching for:", icon: .search)

// Search tips
SectionHeader(title: "Search Tips", icon: .info)
```

### Step 6: Update Tags with Pill Style

**File:** `SearchView.swift`

```swift
// Popular searches with pill style
LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
    ForEach(viewModel.popularSearches, id: \.self) { search in
        DSTag(
            title: search,
            style: .pill,
            action: {
                viewModel.searchQuery = search
                viewModel.performSearch()
            }
        )
    }
}

// Alternative suggestions with outlined style
LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
    ForEach(suggestions, id: \.self) { suggestion in
        DSTag(
            title: suggestion,
            style: .outlined,
            action: {
                viewModel.searchQuery = suggestion
                viewModel.performSearch()
            }
        )
    }
}
```

## Todo Checklist

- [ ] Add `totalResults` property to SearchViewModel
- [ ] Create resultsCountHeader view
- [ ] Enhance DSTag with style variants (pill, outlined)
- [ ] Create SectionHeader component
- [ ] Replace all manual section headers
- [ ] Update tag styles throughout SearchView
- [ ] Verify visual consistency

## Visual Hierarchy Guidelines

| Element | Weight | Color | Size |
|---------|--------|-------|------|
| Section title | Semibold | primaryText | h5 (14pt) |
| Results count | Medium | secondaryText | bodySmall (12pt) |
| Page info | Regular | tertiaryText | caption (10pt) |
| Tags (default) | Medium | secondaryText | bodySmall |
| Tags (selected) | Medium | accent/background | bodySmall |

## Success Criteria

- [ ] Results count visible above results
- [ ] All sections have icon + title headers
- [ ] Tags use pill/outlined styles consistently
- [ ] Visual weight guides user attention
- [ ] Spacing follows DSSpacing system

## Next Phase

→ [Phase 6: Performance](./phase-06-performance.md)
