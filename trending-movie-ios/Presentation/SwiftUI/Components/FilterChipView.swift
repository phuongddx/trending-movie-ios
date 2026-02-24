import SwiftUI

// MARK: - FilterChipView
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
            .accessibilityLabel("Remove \(chip.label) filter")
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xs)
        .background(DSColors.surfaceSwiftUI)
        .cornerRadius(DSSpacing.CornerRadius.medium)
    }
}

// MARK: - ActiveFiltersBar
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
                .accessibilityLabel(filters.isActive ? "Open filters, \(filters.activeChips.count) filters active" : "Open filters")

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
                    .accessibilityLabel("Clear all filters")
                }
            }
            .padding(.horizontal, DSSpacing.Padding.container)
        }
    }

    private func removeChip(_ chip: FilterChip) {
        let currentYear = Calendar.current.component(.year, from: Date())
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
            filters.yearRange = 1990...currentYear
        }
    }
}

// MARK: - Preview
struct FilterChipView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            FilterChipView(
                chip: FilterChip(id: "genre_28", label: "Action", category: .genre),
                onRemove: {}
            )
            FilterChipView(
                chip: FilterChip(id: "rating", label: "Rating: 7.0+", category: .rating),
                onRemove: {}
            )
        }
        .padding()
        .background(DSColors.backgroundSwiftUI)
        .previewLayout(.sizeThatFits)
    }
}
