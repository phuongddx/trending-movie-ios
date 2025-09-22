import SwiftUI

struct AgeRatingBadge: View {
    let rating: String

    var body: some View {
        Text(rating)
            .font(DSTypography.captionSwiftUI(weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, DSSpacing.xs)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private var backgroundColor: Color {
        switch rating {
        case "R", "18+", "NC-17":
            return Color.red
        case "PG-13", "13+", "T":
            return Color.orange
        case "PG", "7+":
            return Color.blue
        case "G", "U", "All":
            return Color.green
        default:
            return DSColors.secondaryTextSwiftUI
        }
    }
}

struct AgeRatingBadge_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 16) {
            AgeRatingBadge(rating: "R 17+")
            AgeRatingBadge(rating: "PG-13")
            AgeRatingBadge(rating: "PG")
            AgeRatingBadge(rating: "G")
        }
        .padding()
        .background(DSColors.backgroundSwiftUI)
    }
}