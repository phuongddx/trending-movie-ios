import SwiftUI

struct RatingDistribution: View {
    let voteAverage: Double
    let voteCount: Int
    let distribution: [Int]? // Array of 10 elements representing votes for ratings 1-10

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            // Header
            Text("Rating")
                .font(DSTypography.h4SwiftUI(weight: .semibold))
                .foregroundColor(DSColors.primaryTextSwiftUI)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Rating and review count
            HStack(spacing: DSSpacing.lg) {
                // Rating number
                VStack(spacing: DSSpacing.xs) {
                    Text(String(format: "%.1f", voteAverage))
                        .font(DSTypography.h1SwiftUI(weight: .semibold))
                        .foregroundColor(DSColors.primaryTextSwiftUI)

                    // Stars
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: starType(for: index))
                                .font(.system(size: 14))
                                .foregroundColor(.yellow)
                        }
                    }

                    Text(formatVoteCount(voteCount))
                        .font(DSTypography.captionSwiftUI())
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                }

                // Distribution bars
                if let distribution = distribution {
                    VStack(spacing: 0) {
                        ForEach(Array(distribution.enumerated().reversed()), id: \.offset) { index, count in
                            HStack(spacing: DSSpacing.xs) {
                                Text("\(10 - index)")
                                    .font(DSTypography.captionSwiftUI())
                                    .foregroundColor(DSColors.secondaryTextSwiftUI)
                                    .frame(width: 15, alignment: .trailing)

                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        // Background bar
                                        Rectangle()
                                            .fill(DSColors.surfaceSwiftUI)
                                            .frame(height: 4)
                                            .cornerRadius(2)

                                        // Filled bar
                                        Rectangle()
                                            .fill(barColor(for: 10 - index))
                                            .frame(width: calculateBarWidth(count: count, totalWidth: geometry.size.width), height: 4)
                                            .cornerRadius(2)
                                    }
                                }
                                .frame(height: 12)
                            }
                        }
                    }
                } else {
                    // If no distribution data, show simple histogram placeholder
                    distributionPlaceholder
                }
            }
        }
    }

    private func starType(for index: Int) -> String {
        let fillPercentage = (voteAverage / 2.0) - Double(index)
        if fillPercentage >= 1.0 {
            return "star.fill"
        } else if fillPercentage > 0 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }

    private func formatVoteCount(_ count: Int) -> String {
        if count >= 1000 {
            let thousands = Double(count) / 1000.0
            return String(format: "(%.1fk reviews)", thousands)
        } else {
            return "(\(count) reviews)"
        }
    }

    private func calculateBarWidth(count: Int, totalWidth: CGFloat) -> CGFloat {
        guard let distribution = distribution else { return 0 }
        let maxCount = distribution.max() ?? 1
        guard maxCount > 0 else { return 0 }
        return CGFloat(count) / CGFloat(maxCount) * totalWidth
    }

    private func barColor(for rating: Int) -> Color {
        if rating >= 7 {
            return Color.green
        } else if rating >= 5 {
            return Color.yellow
        } else {
            return Color.red
        }
    }

    private var distributionPlaceholder: some View {
        VStack(spacing: 0) {
            ForEach(0..<10) { index in
                HStack(spacing: DSSpacing.xs) {
                    Text("\(10 - index)")
                        .font(DSTypography.captionSwiftUI())
                        .foregroundColor(DSColors.secondaryTextSwiftUI)
                        .frame(width: 15, alignment: .trailing)

                    GeometryReader { geometry in
                        Rectangle()
                            .fill(DSColors.surfaceSwiftUI)
                            .frame(height: 4)
                            .cornerRadius(2)
                    }
                    .frame(height: 12)
                }
            }
        }
    }
}

struct RatingDistribution_Previews: PreviewProvider {
    static var previews: some View {
        RatingDistribution(
            voteAverage: 8.9,
            voteCount: 2400,
            distribution: [50, 30, 20, 40, 100, 200, 400, 600, 500, 300]
        )
        .padding()
        .background(DSColors.backgroundSwiftUI)
    }
}