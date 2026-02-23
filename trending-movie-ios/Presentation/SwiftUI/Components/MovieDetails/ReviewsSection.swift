import SwiftUI

struct ReviewsSection: View {
    let reviews: [Review]

    private var displayReviews: [Review] {
        Array(reviews.prefix(3))
    }

    var body: some View {
        if !reviews.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Reviews")
                        .font(DSTypography.h4SwiftUI(weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    if reviews.count > 3 {
                        Button("See All") {
                            // Navigate to full reviews
                        }
                        .font(DSTypography.h5SwiftUI(weight: .medium))
                        .foregroundColor(Color(hex: "#12CDD9"))
                    }
                }

                ForEach(displayReviews) { review in
                    ReviewCard(review: review)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
        }
    }
}

struct ReviewCard: View {
    let review: Review
    @State private var isExpanded = false

    private var displayContent: String {
        if isExpanded || review.content.count <= 200 {
            return review.content
        }
        let endIndex = review.content.index(review.content.startIndex, offsetBy: 200)
        return String(review.content[..<endIndex]) + "..."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Author Header
            HStack(spacing: 12) {
                // Avatar
                if let avatarURL = review.avatarURL {
                    AsyncImage(url: avatarURL) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle().fill(DSColors.surfaceSwiftUI)
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(DSColors.surfaceSwiftUI)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(review.author.prefix(1)).uppercased())
                                .font(DSTypography.h5SwiftUI(weight: .semibold))
                                .foregroundColor(.white)
                        )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(review.author)
                        .font(DSTypography.h5SwiftUI(weight: .semibold))
                        .foregroundColor(.white)

                    if let rating = review.authorRating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(DSTypography.captionSwiftUI(weight: .medium))
                                .foregroundColor(DSColors.secondaryTextSwiftUI)
                            Text("/ 10")
                                .font(DSTypography.captionSwiftUI(weight: .regular))
                                .foregroundColor(DSColors.secondaryTextSwiftUI)
                        }
                    }
                }

                Spacer()
            }

            // Content
            Text(displayContent)
                .font(DSTypography.h5SwiftUI(weight: .regular))
                .foregroundColor(DSColors.secondaryTextSwiftUI)
                .lineLimit(isExpanded ? nil : 4)

            if review.content.count > 200 {
                Button(isExpanded ? "Less" : "Read more") {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isExpanded.toggle()
                    }
                }
                .font(DSTypography.h5SwiftUI(weight: .medium))
                .foregroundColor(Color(hex: "#12CDD9"))
            }
        }
        .padding(16)
        .background(DSColors.surfaceSwiftUI)
        .cornerRadius(12)
    }
}
