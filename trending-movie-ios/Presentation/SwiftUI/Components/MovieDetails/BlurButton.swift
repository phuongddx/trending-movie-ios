import SwiftUI

struct BlurButton: View {
    let icon: String
    let size: CGFloat
    let iconColor: Color
    let backgroundColor: Color
    let action: () -> Void

    init(
        icon: String,
        size: CGFloat = 48,
        iconColor: Color = .white,
        backgroundColor: Color = DSColors.surfaceSwiftUI,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.iconColor = iconColor
        self.backgroundColor = backgroundColor
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .background(
                        VisualEffectBlur(blurStyle: .systemThinMaterialDark)
                            .clipShape(Circle())
                    )

                Image(systemName: icon)
                    .font(.system(size: size * 0.5, weight: .medium))
                    .foregroundColor(iconColor)
            }
            .frame(width: size, height: size)
        }
    }
}

struct MetadataItem: View {
    let icon: String
    let text: String
    let iconColor: Color

    init(icon: String, text: String, iconColor: Color = DSColors.secondaryTextSwiftUI) {
        self.icon = icon
        self.text = text
        self.iconColor = iconColor
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(iconColor)

            Text(text)
                .font(DSTypography.h6SwiftUI(weight: .medium))
                .foregroundColor(DSColors.secondaryTextSwiftUI)
        }
    }
}

struct RatingBadge: View {
    let rating: Double
    let maxRating: Double

    init(rating: Double, maxRating: Double = 10.0) {
        self.rating = rating
        self.maxRating = maxRating
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#FF8700"))

            Text(String(format: "%.1f", rating))
                .font(DSTypography.h6SwiftUI(weight: .semibold))
                .foregroundColor(Color(hex: "#FF8700"))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Color.black.opacity(0.32)
                .background(
                    VisualEffectBlur(blurStyle: .systemUltraThinMaterialDark)
                )
                .cornerRadius(8)
        )
    }
}

struct MetadataDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color(hex: "#696974"))
            .frame(width: 1, height: 16)
    }
}

