import SwiftUI

// MARK: - Genre Item for UI
private struct GenreItem: Identifiable {
    let id: Int
    let name: String
}

private let genreItems: [GenreItem] = [
    GenreItem(id: 28, name: "Action"),
    GenreItem(id: 12, name: "Adventure"),
    GenreItem(id: 16, name: "Animation"),
    GenreItem(id: 35, name: "Comedy"),
    GenreItem(id: 80, name: "Crime"),
    GenreItem(id: 99, name: "Documentary"),
    GenreItem(id: 18, name: "Drama"),
    GenreItem(id: 10751, name: "Family"),
    GenreItem(id: 14, name: "Fantasy"),
    GenreItem(id: 36, name: "History"),
    GenreItem(id: 27, name: "Horror"),
    GenreItem(id: 10402, name: "Music"),
    GenreItem(id: 9648, name: "Mystery"),
    GenreItem(id: 10749, name: "Romance"),
    GenreItem(id: 878, name: "Science Fiction"),
    GenreItem(id: 53, name: "Thriller"),
    GenreItem(id: 10752, name: "War"),
    GenreItem(id: 37, name: "Western")
]

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
                    .font(DSTypography.bodyMediumSwiftUI(weight: .semibold))
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
                ForEach(genreItems) { genre in
                    genreChip(genre)
                }
            }
        }
    }

    private func genreChip(_ genre: GenreItem) -> some View {
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
                        set: { newValue in
                            let upper = max(localFilters.yearRange.upperBound, newValue)
                            localFilters.yearRange = newValue...upper
                        }
                    ))
                }

                VStack(alignment: .leading) {
                    Text("To")
                        .font(DSTypography.captionSwiftUI())
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                    yearPicker(binding: Binding(
                        get: { localFilters.yearRange.upperBound },
                        set: { newValue in
                            let lower = min(localFilters.yearRange.lowerBound, newValue)
                            localFilters.yearRange = lower...newValue
                        }
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

// MARK: - Preview
struct MoviesFilterView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesFilterView(filters: .constant(.default))
    }
}
