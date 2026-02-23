import SwiftUI

// MARK: - Skeleton Rectangle
struct SkeletonRectangle: View {
    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat

    init(width: CGFloat? = nil, height: CGFloat, cornerRadius: CGFloat = 8) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        Rectangle()
            .fill(DSColors.surfaceSwiftUI)
            .frame(width: width, height: height)
            .cornerRadius(cornerRadius)
            .shimmer()
    }
}

// MARK: - Movie Card Skeleton
struct MovieCardSkeleton: View {
    let style: MovieCardStyle

    init(style: MovieCardStyle = .standard) {
        self.style = style
    }

    var body: some View {
        switch style {
        case .standard:
            standardSkeleton
        case .hero:
            heroSkeleton
        case .compact:
            compactSkeleton
        }
    }

    private var standardSkeleton: some View {
        VStack(spacing: 0) {
            SkeletonRectangle(width: 135, height: 178, cornerRadius: 12)
                .cornerRadius(12, corners: [.topLeft, .topRight])

            VStack(alignment: .leading, spacing: 4) {
                SkeletonRectangle(width: 100, height: 16, cornerRadius: 4)
                SkeletonRectangle(width: 60, height: 12, cornerRadius: 4)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .frame(width: 135, alignment: .leading)
        }
        .background(DSColors.surfaceSwiftUI)
        .cornerRadius(12)
    }

    private var heroSkeleton: some View {
        VStack(alignment: .leading, spacing: 16) {
            SkeletonRectangle(width: nil, height: 300, cornerRadius: 0)

            VStack(alignment: .leading, spacing: 8) {
                SkeletonRectangle(width: 200, height: 24, cornerRadius: 4)
                SkeletonRectangle(width: 100, height: 14, cornerRadius: 4)
            }
            .padding(.horizontal, 20)
        }
    }

    private var compactSkeleton: some View {
        HStack(spacing: 12) {
            SkeletonRectangle(width: 60, height: 90, cornerRadius: 8)

            VStack(alignment: .leading, spacing: 8) {
                SkeletonRectangle(width: 150, height: 16, cornerRadius: 4)
                SkeletonRectangle(width: 80, height: 12, cornerRadius: 4)
                SkeletonRectangle(width: nil, height: 12, cornerRadius: 4)
            }

            Spacer()
        }
        .padding(16)
        .background(DSColors.surfaceSwiftUI)
        .cornerRadius(12)
    }
}

/// Movie card style enum for skeleton
enum MovieCardStyle {
    case standard
    case hero
    case compact
}

// MARK: - Preview
struct SkeletonViews_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            MovieCardSkeleton(style: .standard)
            MovieCardSkeleton(style: .compact)
        }
        .padding()
        .background(DSColors.backgroundSwiftUI)
    }
}
