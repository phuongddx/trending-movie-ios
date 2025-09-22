import SwiftUI

struct RateMovieSheet: View {
    let movie: Movie
    let onSubmit: (Int) -> Void

    @Environment(\.dismiss) var dismiss
    @State private var selectedRating: Int = 0
    @State private var hoveredRating: Int = 0

    var body: some View {
        NavigationView {
            VStack(spacing: DSSpacing.xl) {
                // Movie info
                VStack(spacing: DSSpacing.md) {
                    Text(movie.title ?? "Rate This Movie")
                        .font(DSTypography.h3SwiftUI(weight: .semibold))
                        .foregroundColor(DSColors.primaryTextSwiftUI)
                        .multilineTextAlignment(.center)

                    Text("How would you rate this movie?")
                        .font(DSTypography.bodyMediumSwiftUI())
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                }
                .padding(.top, DSSpacing.lg)

                // Rating stars (10 stars for 1-10 rating)
                VStack(spacing: DSSpacing.md) {
                    // Stars in two rows
                    VStack(spacing: DSSpacing.sm) {
                        HStack(spacing: DSSpacing.sm) {
                            ForEach(1...5, id: \.self) { rating in
                                StarButton(
                                    rating: rating,
                                    isSelected: selectedRating >= rating,
                                    isHovered: hoveredRating >= rating
                                ) {
                                    selectedRating = rating
                                }
                            }
                        }

                        HStack(spacing: DSSpacing.sm) {
                            ForEach(6...10, id: \.self) { rating in
                                StarButton(
                                    rating: rating,
                                    isSelected: selectedRating >= rating,
                                    isHovered: hoveredRating >= rating
                                ) {
                                    selectedRating = rating
                                }
                            }
                        }
                    }

                    // Selected rating display
                    if selectedRating > 0 {
                        Text("\(selectedRating)/10")
                            .font(DSTypography.h2SwiftUI(weight: .semibold))
                            .foregroundColor(DSColors.accentSwiftUI)
                    }
                }

                Spacer()

                // Action buttons
                VStack(spacing: DSSpacing.sm) {
                    DSActionButton(
                        title: "Submit Rating",
                        style: .primary
                    ) {
                        if selectedRating > 0 {
                            onSubmit(selectedRating)
                            dismiss()
                        }
                    }
                    .disabled(selectedRating == 0)

                    DSActionButton(
                        title: "Cancel",
                        style: .text
                    ) {
                        dismiss()
                    }
                }
                .padding(.bottom, DSSpacing.md)
            }
            .padding(.horizontal, DSSpacing.Padding.container)
            .background(DSColors.backgroundSwiftUI)
            .navigationBarHidden(true)
        }
    }
}

struct StarButton: View {
    let rating: Int
    let isSelected: Bool
    let isHovered: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Image(systemName: isSelected ? "star.fill" : "star")
                .font(.system(size: 32))
                .foregroundColor(isSelected ? Color.yellow : DSColors.secondaryTextSwiftUI)
                .scaleEffect(isHovered ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isHovered)
        }
    }
}

struct RateMovieSheet_Previews: PreviewProvider {
    static var previews: some View {
        RateMovieSheet(
            movie: Movie(
                id: "1",
                title: "Deadpool 3",
                posterPath: nil,
                overview: nil,
                releaseDate: nil,
                voteAverage: "8.5"
            ),
            onSubmit: { rating in
                print("Rated: \(rating)")
            }
        )
    }
}